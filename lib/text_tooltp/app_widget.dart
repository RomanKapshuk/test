import 'package:flutter/material.dart';

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

class HomeWidget extends StatelessWidget {
  HomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ...List<Widget>.generate(
                20,
                (index) => Container(
                  color: Colors.red,
                  margin: const EdgeInsets.only(top: 150),
                  child: const TextField(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
