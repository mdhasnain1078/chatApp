import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final firestore = FirebaseFirestore.instance;
var loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final auth = FirebaseAuth.instance;
  String massageText;

  void getCurrentUser() async {
    final user = await auth.currentUser;
    try {
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  // void getMessage() async {
  //   final massages = await firestore.collection('messages').get();
  //   for (var massage in massages.docs) {
  //     print(massage.data());
  //   }
  // }

  // void messageSteam() async {
  //   await for (var snapshot in firestore.collection('messages').snapshots()) {
  //     for (var message in snapshot.docs) {
  //       print(message.data());
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                auth.signOut();
                Navigator.pop(context);
                // getMessage();
                // messageSteam();
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MesssageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      style: TextStyle(color: Colors.black),
                      onChanged: (value) {
                        massageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageTextController.clear();
                      firestore.collection('messages').add(
                          {'text': massageText, 'sender': loggedInUser.email});
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MesssageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('messages').snapshots(),
        // ignore: missing_return
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            Center(
                child: CircularProgressIndicator(
              backgroundColor: Colors.blueAccent,
            ));
          }
          final messages = snapshot.data.docs.reversed;
          List<MessageBubble> messageBubbles = [];
          for (var message in messages) {
            final data = Map.from(message.data());
            final messageText = data['text'];
            final messageSender = data['sender'];

            final currentUser = loggedInUser.email;
            if (currentUser == messageSender) {}

            final messageWidget = MessageBubble(
              text: messageText,
              send: messageSender,
              isMe: currentUser == messageSender,
            );
            messageBubbles.add(messageWidget);
          }
          return Expanded(
            child: ListView(
              reverse: true,
              children: messageBubbles,
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
            ),
          );
        });
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({this.text, this.send, this.isMe});

  final String text;
  final String send;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            '${send}',
            style: TextStyle(color: Colors.black54, fontSize: 12.0),
          ),
          Material(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0)),
              elevation: 5.0,
              color: isMe ? Colors.lightBlueAccent : Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                child: Text(
                  '${text}',
                  style: TextStyle(
                      color: isMe ? Colors.white : Colors.black54,
                      fontSize: 15.0),
                ),
              )),
        ],
      ),
    );
  }
}
