import 'package:flutter/material.dart';
import 'package:trabalho_loc_ai/controller/controller.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);

}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  initializeFirebase();

  runApp(const MyApp());
}
