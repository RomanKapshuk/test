import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:test/router_outlet/app/modules/start/start_module.dart';
import 'package:test/router_outlet/app/modules/start/start_page.dart';

class AppModule extends Module {
  @override
  final List<Bind> binds = [];

  @override
  final List<ModularRoute> routes = [
    ModuleRoute(
      '/',
      module: StartModule(),
    ),
    ChildRoute(
      '/page1',
      child: (context, args) => const InternalPage(title: 'go deeper', color: Colors.yellow),
    ),
  ];
}
