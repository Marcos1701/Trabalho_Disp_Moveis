import 'package:flutter/material.dart';
import 'package:trabalho_loc_ai/view/auth/sign_in/view.dart';
import 'package:trabalho_loc_ai/view/auth/sign_up/view.dart';
import 'package:trabalho_loc_ai/view/home/view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const SingInPage(),
        '/home': (context) => const LocationMap(),
        '/signup': (context) => const SignUpPage(),
      },
    );
  }
}
