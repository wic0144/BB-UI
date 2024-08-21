import 'package:flutter/material.dart';

class RecentChatItem extends StatelessWidget {
  final String name;
  final String time;
  final String messagePreview;
  final Color avatarColor;

  RecentChatItem({
    required this.name,
    required this.time,
    required this.messagePreview,
    required this.avatarColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: avatarColor,
        radius: 25,
      ),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        messagePreview,
        style: TextStyle(
          color: Colors.white70,
        ),
      ),
      trailing: Text(
        time,
        style: TextStyle(
          color: Colors.white54,
        ),
      ),
    );
  }
}