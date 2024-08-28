import 'package:flutter/material.dart';
import 'package:trabalho_loc_ai/view/view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(),
        // initialRoute: '/login',
        routes: {
          '/': (context) => const MyHomePage(),
          // '/login': (context) => const LoginPage(),
          // '/cadastro': (context) => const CadastroPage(),

        },

        );
  }
}
