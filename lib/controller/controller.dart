import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trabalho_loc_ai/view/auth/sign_in/view.dart';
import 'package:trabalho_loc_ai/view/home/view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Roteador(),
    );
  }
}

class Roteador extends StatelessWidget {
  const Roteador({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const LocationMap();
        }
        return const SingInPage();
      },
    );
  }
}
