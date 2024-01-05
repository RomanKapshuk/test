import 'package:flutter_modular/flutter_modular.dart';

import 'users_page.dart';

class UsersModule extends Module {
  @override
  final List<ModularRoute> routes = [
    ChildRoute('/', child: (_, args) => UsersPage()),
  ];
}
