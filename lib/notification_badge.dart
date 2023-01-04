import 'package:flutter/material.dart';
class NotificationBadge extends StatelessWidget {
  NotificationBadge({Key? key,required this.totalNotification}) : super(key: key);
  int totalNotification;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: 60,
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Colors.redAccent,
        shape: BoxShape.circle
      ),
      child: Text(totalNotification.toString(),),
    );
  }
}
