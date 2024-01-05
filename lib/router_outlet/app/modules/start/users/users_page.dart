import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter/material.dart';

class UsersPage extends StatefulWidget {
  final String title;
  const UsersPage({Key? key, this.title = 'UsersPage'}) : super(key: key);
  @override
  UsersPageState createState() => UsersPageState();
}

class UsersPageState extends State<UsersPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Hi! This is the UserModule inside StartModule'),
      ],
    );
  }
}
