// Geovanna Kaori Shimada e Jamile Franquilim de Oliveira

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyLoginPage extends StatefulWidget {

  const MyLoginPage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<MyLoginPage> createState() =>
      _MyLoginPageState();
}

class _MyLoginPageState
    extends State<MyLoginPage> {

  final _emailController =
      TextEditingController();

  final _senhaController =
      TextEditingController();

  bool carregando = false;

  Future<void> _fazerLogin() async {

    setState(() {
      carregando = true;
    });

    try {

      await Supabase.instance.client.auth
          .signInWithPassword(

        email:
            _emailController.text.trim(),

        password:
            _senhaController.text.trim(),
      );

      if (mounted) {

        Navigator.pop(context);
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
                        : _fazerLogin,

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
                            'Entrar',
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