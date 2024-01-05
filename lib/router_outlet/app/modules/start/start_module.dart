import 'package:test/router_outlet/app/modules/start/pages/configuration_page.dart';
import 'package:test/router_outlet/app/modules/start/start_store.dart';
import 'package:flutter_modular/flutter_modular.dart';
import './start_page.dart';
import 'profile/profile_store.dart';

class StartModule extends Module {
  @override
  final List<ModularRoute> routes = [
    ChildRoute('/', child: (_, args) => const StartPage(), children: [
      ModuleRoute(
        '/firstTab',
        module: FirstModule(),
      ),
      ChildRoute('/secondTab', child: (_, args) => const SecondTab()),
      ChildRoute('/thirdTab', child: (_, args) => const ThirdTab())
    ]),
  ];
}
