import 'dart:io';

import 'package:flutter/material.dart';

import 'test_text_form_field.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Smart App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeWidget(),
    );
  }
}

class _CustomErrorNotifier extends ValueNotifier<String?> {
  _CustomErrorNotifier({String? value}) : super(value);
}

class HomeWidget extends StatefulWidget {
  HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> with WidgetsBindingObserver {
  final errorNotifier = _CustomErrorNotifier();
  final TextEditingController _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  // Key visibilityKey = UniqueKey();

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    final isBackground = state == AppLifecycleState.resumed || state == AppLifecycleState.inactive;

    if (Platform.isAndroid && _passwordFocusNode.hasFocus && state == AppLifecycleState.resumed) {
      _passwordFocusNode.unfocus();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              color: Colors.grey,
              child: TextFormField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
