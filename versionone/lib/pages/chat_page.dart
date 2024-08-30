import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:versionone/component/message_box.dart';
import 'package:versionone/component/textfield.dart';
import 'package:versionone/services/chat/chat_service.dart';
import 'package:versionone/security/sha3.dart';
import 'dart:math';

class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;
  const ChatPage({
    super.key,
    required this.receiverUserEmail,
    required this.receiverUserID,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  void sendMessage() async {
    // send message only if the message not empty
    if (_messageController.text.isNotEmpty) {
      String message = _messageController.text;
      String hash = SHA3.hash(message);
      
      int corruptChance = Random().nextInt(2);
      if (corruptChance == 1) {
        message = message + "#";
      }
      
      await _chatService.sendMessage(widget.receiverUserID, message, hash);

      // clear the controller after sending a message
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.receiverUserEmail,
        ),
      ),
      body: Column(
        children: [
          // message
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firebaseFirestore
                  .collection('chat_room')
                  .doc(getChatRoomId())
                  .collection('message')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                List<MessageBox> messageWidgets = [];
                if (snapshot.hasError) {
                  return Text('Error ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Loading..');
                }
                if (snapshot.hasData) {
                  final messages = snapshot.data!.docs;
                  for (var message in messages) {
                    final receivedMessage = message.get('message');
                    final senderEmail = message.get('senderEmail');
                    final consistency =
                        verifikasi(receivedMessage, message.get('hash'));
                    var color = consistency
                        ? Colors.blue.shade300
                        : Colors.amber.shade300;
                    var errorMessage = consistency
                        ? Text(
                            "Secure",
                            style: TextStyle(
                                fontWeight: FontWeight.w200,
                                fontStyle: FontStyle.italic),
                          )
                        : Text(
                            "Message Modified!",
                            style: TextStyle(
                                fontWeight: FontWeight.w200,
                                fontStyle: FontStyle.italic),
                          );
                    var alignment = (message.get('senderId') ==
                            _firebaseAuth.currentUser!.uid)
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start;
                    final messageWidget = MessageBox(
                      message: receivedMessage,
                      sender: senderEmail,
                      alignment: alignment,
                      color: color,
                      errorMessage: errorMessage,
                    );
                    messageWidgets.add(messageWidget);
                  }

                  return ListView(
                    padding:
                        EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                    children: messageWidgets,
                  );
                } else {
                  return Column(
                    children: [Text('Gak ada data')],
                  );
                }
              },
            ),
          ),

          // chat input
          _buildMessageInput()
        ],
      ),
    );
  }

  bool verifikasi(String receivedMessage, String receivedHash) {
    String calculatedHash =
        hashReceived(receivedMessage); // Hitung hash pesan yang diterima
    return calculatedHash ==
        receivedHash; // Periksa apakah hash yang diterima sama dengan hash yang dikirimkan
  }

  String hashReceived(String receivedMessage) {
    return SHA3.hash(receivedMessage); // Menghitung hash pesan yang diterima
  }

  String getChatRoomId() {
    List<String> ids = [_firebaseAuth.currentUser!.uid, widget.receiverUserID];
    ids.sort();
    String chatRoomId = ids.join("_");
    return chatRoomId;
  }

// build message message input
  Widget _buildMessageInput() {
    return Row(
      children: [
        // textfield
        Expanded(
          child: CustomTextField(
            controller: _messageController,
            hintText: "Masukan pesan",
            obscureText: false,
          ),
        ),

        IconButton(
          onPressed: sendMessage,
          icon: Icon(
            Icons.arrow_right_alt_rounded,
            size: 40,
          ),
        ),
      ],
    );
  }
}
