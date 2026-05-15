import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PerfilPage extends StatefulWidget {

  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() =>
      _PerfilPageState();
}

class _PerfilPageState
    extends State<PerfilPage> {

  Map<String, dynamic>? profile;

  List posts = [];

  bool carregando = true;

  @override
  void initState() {

    super.initState();

    carregarPerfil();
  }

  Future<void> carregarPerfil() async {

    final user =
        Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    try {

      final profileResponse =
          await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      final postsResponse =
          await Supabase.instance.client
          .from('posts')
          .select()
          .eq('user_id', user.id)
          .order(
            'created_at',
            ascending: false,
          );

      setState(() {

        profile = profileResponse;

        posts = postsResponse;

        carregando = false;
      });

    } catch (e) {

      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {

    if (carregando) {

      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(

      appBar: AppBar(
        title: const Text('Perfil'),
      ),

      body: Center(

        child: SizedBox(
          width: 600,

          child: Column(
            children: [

              const SizedBox(height: 30),

              CircleAvatar(

                radius: 50,

                backgroundImage:

                    profile!['foto_perfil'] != null &&
                    profile!['foto_perfil']
                        .toString()
                        .isNotEmpty

                    ? NetworkImage(
                        profile!['foto_perfil'],
                      )

                    : null,

                child:

                    profile!['foto_perfil'] == null ||
                    profile!['foto_perfil']
                        .toString()
                        .isEmpty

                    ? const Icon(
                        Icons.person,
                        size: 50,
                      )

                    : null,
              ),

              const SizedBox(height: 20),

              Text(

                profile!['nome'] ?? '',

                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              Expanded(

                child: ListView.builder(

                  itemCount: posts.length,

                  itemBuilder:
                      (context, index) {

                    final post = posts[index];

                    return Card(

                      child: Padding(
                        padding:
                            const EdgeInsets.all(16),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            Text(
                              post['conteudo'] ?? '',
                            ),

                            if (post['imagem'] != null &&
                                post['imagem']
                                    .toString()
                                    .isNotEmpty)

                              Padding(
                                padding:
                                    const EdgeInsets.only(
                                  top: 10,
                                ),

                                child: Image.network(
                                  post['imagem'],
                                ),
                              ),

                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}