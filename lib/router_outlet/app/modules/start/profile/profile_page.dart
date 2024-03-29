import 'package:flutter_modular/flutter_modular.dart';
import 'package:test/router_outlet/app/modules/start/profile/profile_store.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String? id;
  final String title;
  const ProfilePage({
    Key? key,
    this.title = 'ProfilePage',
    this.id,
  }) : super(key: key);
  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final ProfileStore store = Modular.get();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Hi! This is the ProfileModule inside StartModule. The id is ${widget.id}'),
      ],
    );
  }
}
