import 'package:flutter/material.dart';
import 'package:trabalho_loc_ai/controller/controller.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_config/flutter_config.dart';

Future<void> initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  return;
}

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Required by FlutterConfig
  Future.wait<void>([FlutterConfig.loadEnvVariables(), initializeFirebase()])
      .then((value) {
    runApp(const MyApp());
  });
}
