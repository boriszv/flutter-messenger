import 'package:flutter/material.dart';
import 'package:pa_messenger/pages/login.dart';
import 'package:pa_messenger/routes.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: appRoutes,
      initialRoute: '/login',
    );
  }
}
