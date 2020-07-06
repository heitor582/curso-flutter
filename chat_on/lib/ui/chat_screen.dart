import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:chat_on/ui/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void _sendMessage({String text, File imgFile}) async {
    Map<String, dynamic> data = {};

    if (imgFile != null) {
      StorageUploadTask task = FirebaseStorage.instance
          .ref()
          .child(DateTime.now().millisecondsSinceEpoch.toString())
          .putFile(imgFile);
      StorageTaskSnapshot taskSnapshot = await task.onComplete;
      String url = await taskSnapshot.ref.getDownloadURL();
      data['imgUrl'] = url;
    }
    if (text != null) data['text'] = text;
    Firestore.instance.collection('messages').add({
      'text': text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('messages').snapshots(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  default:
                    List<DocumentSnapshot> documents = snapshot.data.documents;
                    return ListView.builder(
                      itemCount: documents.length,
                      reverse: true,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(documents[index].data['texto']),
                        );
                      },
                    );
                }
              },
            ),
          ),
          TextComposer(_sendMessage),
        ],
      ),
    );
  }
}
