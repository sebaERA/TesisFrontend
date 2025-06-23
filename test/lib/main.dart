import 'package:flutter/material.dart';
import 'config/router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App ELEAM',
      theme: ThemeData(primarySwatch: Colors.indigo),
      initialRoute: '/login',
      routes: appRoutes,
    );
  }
}
