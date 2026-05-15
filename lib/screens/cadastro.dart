// Geovanna Kaori Shimada e Jamile de Oliveira Franquilim

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyCadastroPage
    extends StatefulWidget {

  const MyCadastroPage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<MyCadastroPage> createState() =>
      _MyCadastroPageState();
}

class _MyCadastroPageState
    extends State<MyCadastroPage> {

  final _emailController =
      TextEditingController();

  final _senhaController =
      TextEditingController();

  final _usernameController =
      TextEditingController();

  bool carregando = false;

  Future<void> _fazerCadastro() async {

    setState(() {
      carregando = true;
    });

    try {

      final response =
          await Supabase.instance.client.auth
              .signUp(

        email:
            _emailController.text.trim(),

        password:
            _senhaController.text.trim(),
      );

      final user = response.user;

      // CRIAR PROFILE
      if (user != null) {

        await Supabase.instance.client
            .from('profiles')
            .insert({

          'id': user.id,

          'nome':
              _usernameController.text,

          'email': _emailController.text,

          'foto_perfil': '',

        });
      }

      if (mounted) {

        Navigator.of(context).popUntil(
          (route) => route.isFirst,
        );
      }

    } on AuthException catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
        ),
      );

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            'Erro inesperado: $e',
          ),
        ),
      );

    }

    setState(() {
      carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(widget.title),
      ),

      body: Center(

        child: SizedBox(
          width: 400,

          child: Padding(
            padding:
                const EdgeInsets.all(20),

            child: Column(
              mainAxisSize:
                  MainAxisSize.min,

              children: [

                TextField(
                  controller:
                      _usernameController,

                  decoration:
                      const InputDecoration(
                    labelText: 'Username',
                    border:
                        OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller:
                      _emailController,

                  decoration:
                      const InputDecoration(
                    labelText: 'Email',
                    border:
                        OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller:
                      _senhaController,

                  obscureText: true,

                  decoration:
                      const InputDecoration(
                    labelText: 'Senha',
                    border:
                        OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(

                    onPressed:
                        carregando
                        ? null
                        : _fazerCadastro,

                    child: carregando

                        ? const SizedBox(
                            width: 20,
                            height: 20,

                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )

                        : const Text(
                            'Cadastrar',
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