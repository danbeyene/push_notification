import 'package:flutter/material.dart';

class NotificationBadge extends StatelessWidget {
  NotificationBadge({Key? key, required this.totalNotification})
      : super(key: key);
  int totalNotification;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: 60,
      decoration:
          const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Text(
            totalNotification.toString(),
            style: const TextStyle(fontSize: 35, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
