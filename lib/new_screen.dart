import 'package:flutter/material.dart';
class NewScreen extends StatelessWidget {
  NewScreen({Key? key, required this.info}) : super(key: key);
  String info;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Firebase Messaging'),
      ),
      body: Center(
        child: Text(info),
      ),
    );
  }
}
