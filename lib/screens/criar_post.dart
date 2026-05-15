// Geovanna Kaori Shimada e Jamile de Oliveira Franquilim

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CriarPostPage extends StatefulWidget {

  const CriarPostPage({super.key});

  @override
  State<CriarPostPage> createState() =>
      _CriarPostPageState();
}

class _CriarPostPageState
    extends State<CriarPostPage> {

  final _conteudoController =
      TextEditingController();

  final _imagemController =
      TextEditingController();

  bool carregando = false;

  Future<void> criarPost() async {

    final user =
        Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    setState(() {
      carregando = true;
    });

    try {

      await Supabase.instance.client
          .from('posts')
          .insert({

        'user_id': user.id,

        'conteudo':
            _conteudoController.text,

        'imagem':
            _imagemController.text,

      });

      if (mounted) {

        Navigator.pop(context);
      }

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text('Erro: $e'),
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
        title: const Text('Criar postagem'),
      ),

      body: Center(

        child: SizedBox(
          width: 500,

          child: Padding(
            padding:
                const EdgeInsets.all(20),

            child: Column(
              mainAxisSize:
                  MainAxisSize.min,

              children: [

                TextField(
                  controller:
                      _conteudoController,

                  maxLines: 5,

                  decoration:
                      const InputDecoration(

                    hintText:
                        'O que você está pensando?',

                    border:
                        OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller:
                      _imagemController,

                  decoration:
                      const InputDecoration(

                    hintText:
                        'URL da imagem',

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
                        : criarPost,

                    child: carregando

                        ? const CircularProgressIndicator()

                        : const Text(
                            'Publicar',
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