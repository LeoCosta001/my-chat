import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  // Status
  FirebaseCoreStatus _firebaseIsInitialized = FirebaseCoreStatus.waiting;

  // Methods
  // Initialize firebase core
  Future<void> _initializeFirebaseCore() async {
    Firebase.initializeApp().then((value) {
      setState(() {
        _firebaseIsInitialized = FirebaseCoreStatus.ok;
      });
    }).catchError((onError) {
      setState(() {
        _firebaseIsInitialized = FirebaseCoreStatus.error;
      });
    });
  }

  // Send a new message to Firestore
  Future<void> _createNewMessage({String message = '', bool? isImage}) async {
    FirebaseFirestore.instance.collection('messages').doc().set({isImage == true ? 'imageUrl' : 'text': message});
  }

  // Send a new message or a image (to Firestore and Storage)
  Future<void> _sendMessage({String? message, XFile? imageFile}) async {
    Map<String, dynamic> messagePayload = {};
    if (message != null) {
      _createNewMessage(message: message);
      messagePayload['text'] = message;
    }

    // Send new image to Firebase Storage
    if (imageFile != null) {
      String filePath = 'images/${DateTime.now().millisecondsSinceEpoch.toString()}';
      Reference storageRef = FirebaseStorage.instance.ref().child(filePath);
      UploadTask uploadTask = storageRef.putFile(File(imageFile.path));

      // Action by upload state
      uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
        switch (taskSnapshot.state) {
          case TaskState.running:
            final progress = 100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
            print("Upload is $progress% complete.");
            break;
          case TaskState.paused:
            print("Upload is paused.");
            break;
          case TaskState.canceled:
            print("Upload was canceled");
            break;
          case TaskState.error:
            // Handle unsuccessful uploads
            break;
          case TaskState.success:
            // Handle successful uploads on complete
            // ...
            taskSnapshot.ref.getDownloadURL().then((value) {
              _createNewMessage(message: value, isImage: true);
            });
            break;
        }
      });
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
      appBar: AppBar(
        title: const Text('My Chat'),
        elevation: 0,
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        child: TextComposer(_sendMessage),
      ),
    );
  }
}
