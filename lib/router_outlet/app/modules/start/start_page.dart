import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:test/router_outlet/app/modules/start/start_store.dart';
import 'package:flutter/material.dart';

class StartPage extends StatefulWidget {
  final String title;
  const StartPage({Key? key, this.title = 'StartPage'}) : super(key: key);
  @override
  StartPageState createState() => StartPageState();
}

class StartPageState extends State<StartPage> {
  final PageController controller = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: const RouterOutlet(),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.access_alarms),
            label: 'first',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.security_outlined),
            label: 'second',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cabin),
            label: 'third',
          ),
        ],
        onTap: (value) {
          if (value == 0) {
            Modular.to.navigate('/firstTab');
          } else if (value == 1) {
            Modular.to.navigate('/secondTab');
          } else if (value == 2) {
            Modular.to.navigate('/thirdTab');
          }
          // controller.jumpToPage(value);
        },
      ),
    );
  }
}

class FirstModule extends Module {
  @override
  List<ModularRoute> get routes => [
        ChildRoute(
          Modular.initialRoute,
          child: (context, args) => const FirstTab(),
          children: [],
        ),
        ChildRoute(
          '/internalPage',
          child: (context, args) =>
              const InternalPage(title: 'internal page. Go deeper', color: Colors.red),
        ),
      ];
}

class InternalPage extends StatelessWidget {
  final String title;
  final Color color;
  const InternalPage({Key? key, required this.title, required this.color}) : super(key: key);

  Widget build(BuildContext context) {
    return Scaffold(
      // color: color,
      body: Container(
        constraints: BoxConstraints.expand(),
        color: color,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Modular.to.pop();
              },
              child: Text('back'),
            ),
            TextButton(
              onPressed: () {
                Modular.to.pushNamed('/page1');
              },
              child: Text(title),
            ),
          ],
        ),
      ),
    );
  }
}

class FirstTab extends StatelessWidget {
  const FirstTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        child: const Text('navigate to page1'),
        onPressed: () {
          Modular.to.pushNamed('/firstTab/internalPage');
          // Modular.to.pushNamed('/firstTab/page1');
        },
      ),
    );
  }
}

class SecondTab extends StatelessWidget {
  const SecondTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('SecondTab'),
    );
  }
}

class ThirdTab extends StatelessWidget {
  const ThirdTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('ThirdTab'),
    );
  }
}
