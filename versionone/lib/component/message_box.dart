import 'package:flutter/material.dart';

class MessageBox extends StatelessWidget {
  final message;
  final sender;
  final alignment;
  final color;
  final errorMessage;

  const MessageBox({
    super.key,
    required this.message,
    required this.sender,
    required this.alignment,
    required this.color,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Text('$sender'),
          SizedBox(
            height: 3,
          ),
          Material(
            color: color,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                '$message',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          SizedBox(
            height: 3,
          ),
          errorMessage,
        ],
      ),
    );
  }
}
