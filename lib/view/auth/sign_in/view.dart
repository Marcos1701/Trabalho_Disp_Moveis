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
  late UserCredential _userCredential;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateAndSignIn() async {
    if (_formKey.currentState!.validate()) {
      _userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (_userCredential.user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuário ou senha inválidos')),
          );
        }
        return;
      }

      if (mounted) {
        // Verifica se o widget ainda está montado antes de redirecionar para a próxima rota
        Navigator.pushNamed(context, '/home');
      }
    } else {
      if (mounted) {
        // Verifica se o widget ainda está montado antes de mostrar um SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preencha todos os campos')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página de Login'),
        centerTitle: true,
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
                        _passwordFocus); // Move o foco para o campo de senha
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                  ),
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
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _validateAndSignIn,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                  ),
                  child: const Text('Entrar'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  child: const Text('Cadastrar-se'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
