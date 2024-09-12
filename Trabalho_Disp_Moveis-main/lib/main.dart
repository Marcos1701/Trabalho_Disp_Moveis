import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trabalho_loc_ai/controller/controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trabalho_loc_ai/view/auth/sign_in/view.dart';
import 'package:trabalho_loc_ai/view/home/view.dart';
import 'firebase_options.dart';
import 'package:flutter_config/flutter_config.dart';

Future<void> initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Erro ao inicializar o Firebase: $e');
  }
  return;
}

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Required by FlutterConfig
  Future.wait<void>([FlutterConfig.loadEnvVariables(), initializeFirebase()])
      .then((value) {
    runApp(const MyApp());
  });
}

class RoteadorTela extends StatelessWidget {
  const RoteadorTela({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen(); 
        }

        if (snapshot.hasError) {
          return ErrorScreen(error: snapshot.error.toString()); 
        }

        if (snapshot.hasData) {
          return const LocationMap(); 
        } else {
          return const LoginPage(); 
        }
      },
    );
  }
}

// Widgets de carregamento e erro
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final String error;

  const ErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Erro: $error'),
      ),
    );
  }
}