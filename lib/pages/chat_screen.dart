import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_chat/widgets/chat_message.dart';
import 'package:my_chat/widgets/text_composer.dart';

enum FirebaseCoreStatus {
  ok,
  waiting,
  error,
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Cria uma instancia de logion com a conta do google
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  // States
  User? _currentUser;
  double? _imageUploadProgress;

  // Status
  FirebaseCoreStatus _firebaseIsInitialized = FirebaseCoreStatus.waiting;

  // Methods
  // Initialize firebase core
  Future<void> _initializeFirebaseCore() async {
    Firebase.initializeApp().then((value) {
      setState(() {
        _firebaseIsInitialized = FirebaseCoreStatus.ok;
      });
      _checkUserAuthentication();
    }).catchError((onError) {
      setState(() {
        _firebaseIsInitialized = FirebaseCoreStatus.error;
      });
    });
  }

  // Atualiza automaticamente a autenticação do usuário
  void _checkUserAuthentication() {
    // Sempre que tiver alguma alteração relacionada a autenticação atual do usuário no firebase esta função de callback será executada
    FirebaseAuth.instance.userChanges().listen((User? user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  // Obtem o acesso de um usuário a partir da conta google
  // OBS: Fazendo uma função/fluxo dessa forma faz com que sempre que o usuário estiver expirado sejá obtido um novo acesso
  Future<User?> _getUser() async {
    if (_currentUser != null) return _currentUser;

    try {
      // Obtem as informações de usuário de alguém que fez login com o google
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount == null) return null;

      // Extrair os tokens de autenticação de login
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

      // Cria uma credencial para autenticação de login no Firebase Authentication
      // OBS: Para fazer login com outras contas (facebook, twitter, etc) tambem será usado um método para criar credencial (nos outros casos não será o "GoogleAuthProvider")
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      // Faz login no Firebase Authentication com ama credencial
      // OBS: Para fazer login com outras contas (facebook, twitter, etc) usa credenciais desta mesma forma)
      final UserCredential authResult = await FirebaseAuth.instance.signInWithCredential(credential);

      // Obtem os dados do usuário logado
      final User? user = authResult.user;

      return user;
    } catch (error) {
      return null;
    }
  }

  // Send a new message to Firestore
  Future<void> _createNewMessage(Map<String, dynamic> messagePayload) async {
    FirebaseFirestore.instance.collection('messages').doc().set({
      ...messagePayload,
      'createAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Send a new message or a image (to Firestore and Storage)
  Future<void> _sendMessage({String? message, XFile? imageFile}) async {
    final User? user = await _getUser();
    if (user == null) {
      // Avisa o usuário sobre a falha de autenticação
      _showLoginErrorMessage();
    }

    Map<String, dynamic> messagePayload = {
      'uid': user?.uid,
      'userName': user?.displayName,
      'userPhoto': user?.photoURL,
      'text': null,
      'imageUrl': null
    };

    if (message != null) {
      messagePayload['text'] = message;
      _createNewMessage(messagePayload);
    }

    // Send new image to Firebase Storage
    if (imageFile != null) {
      String filePath = 'images/${DateTime.now().millisecondsSinceEpoch.toString()}';
      Reference storageRef = FirebaseStorage.instance.ref().child(filePath);
      UploadTask uploadTask = storageRef.putFile(File(imageFile.path));

      finishImageUpload() {
        setState(() {
          _imageUploadProgress = null;
        });
      }

      // Action by upload state
      uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
        switch (taskSnapshot.state) {
          case TaskState.running:
            final progress = 100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
            setState(() {
              _imageUploadProgress = progress;
            });
            break;
          case TaskState.paused:
            print("Upload is paused.");
            break;
          case TaskState.canceled:
            print("Upload was canceled");
            finishImageUpload();
            break;
          case TaskState.error:
            // Handle unsuccessful uploads
            finishImageUpload();
            break;
          case TaskState.success:
            // Handle successful uploads on complete
            // ...
            taskSnapshot.ref.getDownloadURL().then((value) {
              messagePayload['imageUrl'] = value;
              _createNewMessage(messagePayload);
            });
            finishImageUpload();
            break;
        }
      });
    }
  }

  // Exibe um Snackbar com a mensagem de erro no login
  void _showLoginErrorMessage() {
    final ScaffoldMessengerState? scaffoldKeyCurrentState = _scaffoldKey.currentState;
    if (scaffoldKeyCurrentState != null) {
      // OBS: Esta é a forma de exibir o snackbar sem o "BuildContext"
      scaffoldKeyCurrentState.showSnackBar(
        const SnackBar(
          content: Text('Authentication error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeFirebaseCore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: _currentUser == null
            ? const Text('My Chat')
            : Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(_currentUser?.photoURL ?? ''),
                    ),
                  ),
                  Text('${_currentUser?.displayName}'),
                ],
              ),
        elevation: 0,
        actions: [
          if (_currentUser != null)
            IconButton(
              onPressed: () {
                // Deslogar do firebase e google
                FirebaseAuth.instance.signOut();
                googleSignIn.signOut();

                // OBS: Esta é a forma de exibir o snackbar com o "BuildContext"
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Successfully logout'),
                  ),
                );
              },
              icon: const Icon(Icons.exit_to_app),
            ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              // O widget "StreamBuilder" vai executar novamente o atributo "builder" sempre que houver alteração no valor do atributo "stream"
              // Neste caso ele será atualizado sempre que houver alteração no documento "message" do banco de dados
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _firebaseIsInitialized == FirebaseCoreStatus.ok
                    ? FirebaseFirestore.instance.collection('messages').orderBy('createAt', descending: true).snapshots()
                    : null,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    default:
                      if (snapshot.data != null) {
                        List<QueryDocumentSnapshot<Map<String, dynamic>>> messageList = snapshot.data!.docs;

                        // A renderização da lista é realizada com o widget "ListView.builder" para que seja rrenderizado em tela apenas o que está sendo visto atualmente pelo usuário
                        return ListView.builder(
                          itemCount: messageList.length,
                          // Faz a lista começar de baixo para cima (no caso as mensagens)
                          reverse: true,
                          itemBuilder: ((context, index) {
                            return ChatMessage(
                              messageList[index].data(),
                              messageList[index].data()['uid'] == _currentUser?.uid,
                            );
                          }),
                        );
                      } else {
                        return const Center(
                          child: Text('Unknown error... :('),
                        );
                      }
                  }
                },
              ),
            ),
            // TODO: Passar logica de upload/sendMessage para dentro de um componente
            _imageUploadProgress != null ? LinearProgressIndicator(value: _imageUploadProgress! / 100) : Container(),
            TextComposer(
              _sendMessage,
              isLogged: _currentUser != null,
              onPressLoginButton: () => _getUser(),
            ),
          ],
        ),
      ),
    );
  }
}
