import 'package:flutter/material.dart';
import 'package:trabalho_loc_ai/controller/controller.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_config/flutter_config.dart';

Future<void> initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  return;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required by FlutterConfig
  await Future.wait<void>([
    FlutterConfig.loadEnvVariables(),
    initializeFirebase()
  ]); // Para executas ambas ao mesmo tempo

  runApp(const MyApp());
}
