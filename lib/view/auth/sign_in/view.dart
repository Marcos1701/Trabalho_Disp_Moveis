import 'package:flutter/material.dart';
import 'package:trabalho_loc_ai/_comum/meu_snackbar.dart';
import 'package:trabalho_loc_ai/view/auth/services/autenticacao_servico.dart';
import 'package:trabalho_loc_ai/view/auth/sign_up/view.dart';
// import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AutenticacaoServico _autenticacaoServico = AutenticacaoServico();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Image(
                    image: AssetImage('assets/logo.png'),
                    width: 150,
                    height: 150,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return "O campo e-mail deve ser preenchido.";
                        }
                        if (value.length < 6) {
                          return "O campo e-mail deve ter pelo menos 6 caracteres.";
                        }
                        if (!value.contains("@")) {
                          return "O campo e-mail deve conter um @.";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(64),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(64),
                            borderSide:
                                const BorderSide(color: Colors.black, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(64),
                            borderSide:
                                const BorderSide(color: Colors.blue, width: 4),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(64),
                            borderSide:
                                const BorderSide(color: Colors.red, width: 2),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(64),
                            borderSide:
                                const BorderSide(color: Colors.red, width: 4),
                          )),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      controller: _passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      autofillHints: const [AutofillHints.password],
                      textInputAction: TextInputAction.done,
                      obscureText: true,
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return "O campo senha deve ser preenchido.";
                        }
                        if (value.length < 8) {
                          return "O campo senha deve ter pelo menos 8 caracteres.";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          labelText: 'Senha',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(64),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(64),
                            borderSide:
                                const BorderSide(color: Colors.black, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(64),
                            borderSide:
                                const BorderSide(color: Colors.blue, width: 4),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(64),
                            borderSide:
                                const BorderSide(color: Colors.red, width: 2),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(64),
                            borderSide:
                                const BorderSide(color: Colors.red, width: 4),
                          )),
                    ),
                  ),
                  /*
                  Row(
                    children: [
                      Checkbox(
                        value: false,
                        onChanged: (value) {
                          //TODO: Implementar
                        },
                      ),
                      const Text('Lembre-me'),
                    ],
                  ),
                  */
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: Colors.green,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(0)),
                      ),
                    ),
                    onPressed: () async {
                      botaoLogin();
                    },
                    child: const Text('Entrar'),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  TextButton(
                    onPressed: () {
                      // Navigator.pushNamed(context, '/register');
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) { 
                          return const RegisterPage(); 
                        }),
                      );
                    },
                    child: const Text(
                        'Ainda não tem uma conta? Clique aqui!'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  botaoLogin() {
    String email = _emailController.text;
    String senha = _passwordController.text;

    if (_formKey.currentState!.validate()) {
      _autenticacaoServico
      .logarUsuario(email: email, senha: senha)
      .then(
        (String? erro) {
          if (erro != null) {
            mostrarSnackBar(context: context, texto: erro);
          }
        },
      );
    } else {
      print('Login falhou!');
    }
  }
}
