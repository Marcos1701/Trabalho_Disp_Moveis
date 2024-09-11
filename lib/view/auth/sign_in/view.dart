import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SingInPage extends StatefulWidget {
  const SingInPage({super.key});

  @override
  State<SingInPage> createState() => _SingInPageState();
}

class _SingInPageState extends State<SingInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    if (_auth.currentUser != null) {
      Navigator.pushNamed(context, '/home');
    }
    super.initState();
  }

  void _validateAndSignIn() {
    if (_formKey.currentState!.validate()) {
      if (_auth.currentUser != null) {
        _auth.signOut().then(
          (value) {
            print("Deslogou");
          },
        );
      }
      _auth
          .signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      )
          .then(
        (value) {
          UserCredential? userCredential = value;
          if (userCredential.user == null) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Usuário ou senha inválidos')),
              );
            }
            return;
          }

          if (mounted) {
            print("Logou");
            Navigator.pushNamed(context, '/home');
          }
        },
      );
    } else {
      // Verifica se o widget ainda está montado antes de mostrar um SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página de Login'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back),
        //   onPressed: () => Navigator.pop(context),
        // ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    icon: Icon(Icons.email),
                    // prefixIcon: Icon(Icons.email),
                    iconColor: Colors.blue,
                    // prefixIconColor: Colors.blue,
                    // prefixStyle: TextStyle(color: Colors.blue),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !value.contains('@') ||
                        !value.contains('.')) {
                      return 'O e-mail é obrigatório';
                    }
                    return null;
                  },
                  autocorrect: false,
                  focusNode: _emailFocus,
                  onFieldSubmitted: (value) {
                    _emailFocus.unfocus();
                    FocusScope.of(context).requestFocus(
                      _passwordFocus,
                    ); // Move o foco para o campo de senha
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    // suffixIcon: Icon(Icons.remove_red_eye),
                    // suffixIconColor: Colors.blue,
                    iconColor: Colors.blue,
                    icon: Icon(Icons.lock_outlined),
                    // prefixIcon: Icon(Icons.remove_red_eye),
                    // prefixIconColor: Colors.blue,
                  ),
                  enableSuggestions: false,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'A senha é obrigatória';
                    }
                    return null;
                  },
                  autocorrect: false,
                  focusNode: _passwordFocus,
                  onFieldSubmitted: (value) {
                    _passwordFocus.unfocus();
                    _validateAndSignIn();
                  },
                  //exibindo botão para esconder a senha
                  // obscureText: _obscureText,
                  showCursor: true,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _validateAndSignIn,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  child: const Text(
                    'Entrar',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(
                      fontSize: 20,
                      decoration: TextDecoration.underline,
                      color: Colors.blue,
                    ),
                  ),
                  child: const Text(
                    'Criar conta',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
