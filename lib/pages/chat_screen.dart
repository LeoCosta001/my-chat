import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
  Future<void> _sendMessage(String message) async {
    FirebaseFirestore.instance.collection('messages').doc().set({'text': message});
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
