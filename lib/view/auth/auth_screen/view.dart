import 'package:flutter/material.dart';
import 'package:trabalho_loc_ai/_comum/meu_snackbar.dart';
import 'package:trabalho_loc_ai/view/auth/services/autenticacao_servico.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  bool queroEntrar = true;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AutenticacaoServico _autenticacaoServico = AutenticacaoServico();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text((queroEntrar) ? 'Entrar' : 'Cadastrar'),
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
                  Visibility(
                    visible: !queroEntrar, 
                    child: Column(
                      children: [
                        SizedBox(
                          width: 300,
                          child: TextFormField(
                            keyboardType: TextInputType.visiblePassword,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            obscureText: true,
                            validator: (String? value) {
                              if (value!.isEmpty) {
                                return "O campo Confirme a senha deve ser preenchido.";
                              }
                              if (value.length < 8) {
                                return "O campo Confirme a senha deve ter pelo menos 8 caracteres.";
                              }
                              if (value != _passwordController.text) {
                                return "As senhas devem ser iguais.";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Confirme a senha',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(64),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(64),
                                borderSide: const BorderSide(
                                    color: Colors.black, width: 2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(64),
                                borderSide: const BorderSide(
                                    color: Colors.blue, width: 4),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(64),
                                borderSide: const BorderSide(
                                    color: Colors.red, width: 2),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(64),
                                borderSide: const BorderSide(
                                    color: Colors.red, width: 4),
                              )
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 300,
                          child: TextFormField(
                            controller: _nameController,
                            keyboardType: TextInputType.name,
                            autofillHints: const [AutofillHints.name],
                            textInputAction: TextInputAction.next,
                            validator: (String? value) {
                              if (value!.isEmpty) {
                                return "O campo Nome Completo deve ser preenchido.";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Nome Completo',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(64),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(64),
                                borderSide: const BorderSide(
                                    color: Colors.black, width: 2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(64),
                                borderSide: const BorderSide(
                                    color: Colors.blue, width: 4),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(64),
                                borderSide: const BorderSide(
                                    color: Colors.red, width: 2),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(64),
                                borderSide: const BorderSide(
                                    color: Colors.red, width: 4),
                              )
                            ),
                          ),
                        ),
                      ]
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: (queroEntrar)? Colors.green : Colors.blue,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(0)),
                      ),
                    ),
                    onPressed: () async {
                      botaoPrincipal();
                    },
                    child: Text((queroEntrar) ? 'Entrar' : 'Cadastrar'),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        queroEntrar = !queroEntrar;
                      });
                    },
                    child: Text(
                        (queroEntrar) ? 'Ainda não tem uma conta? Clique aqui!' : 'Já tem uma conta? Clique aqui!'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  botaoPrincipal() {
    String nome = _nameController.text;
    String email = _emailController.text;
    String senha = _passwordController.text;

    if (_formKey.currentState!.validate()) {
      if (queroEntrar) {
        _autenticacaoServico
        .logarUsuario(email: email, senha: senha)
        .then(
          (String? erro) {
            if (erro != null) {
              mostrarSnackBar(context: context, texto: erro);
            }
          },
        );
        print('Entrada validada');
      } else {
        _autenticacaoServico
        .cadastrarUsuario(nome: nome, email: email, senha: senha)
        .then(
          (String? erro) {
            if (erro != null) {
              mostrarSnackBar(context: context, texto: erro);
            } else {
              mostrarSnackBar(
                context: context,
                texto: 'Cadastro efetuado com sucesso!',
                isError: false,
              );
            }
          },
        );
        print('Cadastro validado');
      }
    } else {
      print('Form inválido');
    }
  }
}