import 'package:flutter/material.dart';
import 'package:trabalho_loc_ai/view/view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // home: MapSample(),
      // initialRoute: '/login',
      initialRoute: '/',
      routes: {
        '/': (context) => const LocationMap(),
        // '/login': (context) => const LoginPage(),
        // '/cadastro': (context) => const CadastroPage(),
      },
    );
  }
}
