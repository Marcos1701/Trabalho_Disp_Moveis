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
  late UserCredential _userCredential;

  late final FirebaseFirestore _firestore;

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _validateAndSignUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        _userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        //salva o usuário no firestore
        _firestore
            .collection('users')
            .doc(_userCredential.user!.uid) //doc do firebase, id do usuário
            .set({'name': _nameController.text});

        if (mounted) {
          Navigator.pushNamed(context, '/home');
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Senha muito fraca')),
            );
          }

          print('Senha muito fraca');
        } else if (e.code == 'email-already-in-use') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Este e-mail ja esta em uso')),
            );
          }

          print('Este e-mail ja esta em uso');
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro ao criar o usuário: ${e.message}')),
            );
          }
          print('Erro ao criar o usuário: ${e.message}');
        }
        print(e.code); //Add this line to see other firebase exceptions.
      } catch (e) {
        print(e);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
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
                onFieldSubmitted: (value) async {
                  _passwordFocus.unfocus();
                  await _validateAndSignUp();
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _validateAndSignUp,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
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
                  ),
                ),
                child: const Text('Ja possuo uma conta'),
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

