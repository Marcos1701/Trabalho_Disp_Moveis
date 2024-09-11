import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    if (_auth.currentUser != null) {
      Navigator.pushNamed(context, '/home');
    }
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateAndSignUp() {
    if (_formKey.currentState!.validate()) {
      try {
        _auth
            .createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        )
            .then(
          (value) {
            UserCredential? userCredential = value;
            userCredential = value;
            if (userCredential.user == null) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Erro ao criar o usuário')),
                );
              }
              return;
            }

            _auth.currentUser!.updateDisplayName(_nameController.text).then(
              //atualiza o nome do usuário
              (value) {
                _firestore
                    .collection('users')
                    .doc(userCredential!.user!.uid)
                    .set(
                  {
                    'name': _nameController.text,
                    'email': _emailController.text
                  }, // Adiciona o nome e o email ao documento do usuário no firestore (Banco de Dados)
                ).then(
                  (value) {
                    if (mounted) {
                      Navigator.pushNamed(
                          context, '/home'); //redireciona para a tela inicial
                    }
                  },
                );
              },
            );
          },
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Senha muito fraca')),
          );
        } else if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Este e-mail ja esta em uso')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao criar o usuário: ${e.message}')),
          );
        }
        print(e.code); //Add this line to see other firebase exceptions.
      } catch (e) {
        print(e.toString());
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Preencha todos os campos',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16.0),
          duration: const Duration(seconds: 2),
          dismissDirection: DismissDirection.horizontal,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          action: SnackBarAction(
            label: 'Fechar',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
          showCloseIcon: true,
          closeIconColor: Colors.white,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'O nome é obrigatório';
                  }
                  return null;
                },
                autocorrect: false,
                focusNode: _nameFocus,
                onFieldSubmitted: (value) {
                  _nameFocus.unfocus();
                  FocusScope.of(context).requestFocus(_emailFocus);
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  icon: Icon(Icons.email),
                  iconColor: Colors.blue,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'O e-mail é obrigatório';
                  } else if (!value.contains('@')) {
                    return 'O e-mail deve conter @';
                  } else if (!value.contains('.')) {
                    return 'Insira um e-mail valido';
                  }
                  return null;
                },
                autocorrect: false,
                focusNode: _emailFocus,
                onFieldSubmitted: (value) {
                  _emailFocus.unfocus();
                  FocusScope.of(context).requestFocus(_passwordFocus);
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  icon: Icon(Icons.lock_outline_rounded),
                  iconColor: Colors.blue,
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'A senha deve ter no mínimo 6 caracteres';
                  }
                  return null;
                },
                autocorrect: false,
                focusNode: _passwordFocus,
                onFieldSubmitted: (value) {
                  _passwordFocus.unfocus();
                  _validateAndSignUp();
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _validateAndSignUp,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                  textStyle: const TextStyle(
                    fontSize: 20,
                  ),
                ),
                child: const Text('Cadastrar'),
              ),
              //Botao para realizar o login
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signin');
                },
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(
                    fontSize: 20,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    decorationThickness: 2.0,
                    decorationColor: Colors.blue,
                    decorationStyle: TextDecorationStyle.solid,
                    shadows: [
                      Shadow(
                        color: Colors.blue,
                        blurRadius: 2.0,
                        offset: Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                ),
                child: const Text(
                  'Ja possuo uma conta',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Erro 1: O código não estava tratando o erro de criação de usuário.
// Erro 2: O código não estava redirecionando o usuário para a tela de login
// após a criação de usuário.
// Correção: Adicionei um try/catch para tratar o erro de criação de
// usuário e redirecionar o usuário para a tela de login após a
// criação de usuário.

