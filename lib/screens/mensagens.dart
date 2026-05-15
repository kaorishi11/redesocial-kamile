// Geovanna Kaori Shimada e Jamile de Oliveira Franquilim

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MensagensPage extends StatefulWidget {

  const MensagensPage({super.key});

  @override
  State<MensagensPage> createState() =>
      _MensagensPageState();
}

class _MensagensPageState
    extends State<MensagensPage> {

  final controller =
      TextEditingController();

  final receiverController =
      TextEditingController();

  List mensagens = [];

  bool carregando = true;

  @override
  void initState() {

    super.initState();

    carregarMensagens();
  }

  Future<void> carregarMensagens() async {

    final user =
        Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    final response =
        await Supabase.instance.client
        .from('messages')
        .select()
        .or(
          'sender_id.eq.${user.id},receiver_id.eq.${user.id}',
        )
        .order(
          'created_at',
          ascending: true,
        );

    // MARCAR COMO VISUALIZADA
    await Supabase.instance.client
        .from('messages')
        .update({
          'visualizada': true,
        })
        .eq('receiver_id', user.id)
        .eq('visualizada', false);

    setState(() {

      mensagens = response;

      carregando = false;
    });
  }

  Future<void> enviarMensagem() async {

    final user =
        Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    if (receiverController.text.isEmpty) {
      return;
    }

    if (controller.text.isEmpty) {
      return;
    }

    await Supabase.instance.client
        .from('messages')
        .insert({

      'sender_id': user.id,

      'receiver_id':
          receiverController.text,

      'mensagem':
          controller.text,
    });

    controller.clear();

    carregarMensagens();
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

    final user =
        Supabase.instance.client.auth.currentUser;

    return Scaffold(

      appBar: AppBar(
        title: const Text('Mensagens'),
      ),

      body: Column(
        children: [

          Padding(
            padding:
                const EdgeInsets.all(12),

            child: TextField(
              controller:
                  receiverController,

              decoration:
                  const InputDecoration(
                labelText:
                    'ID do usuário',
                border:
                    OutlineInputBorder(),
              ),
            ),
          ),

          Expanded(

            child: ListView.builder(

              itemCount:
                  mensagens.length,

              itemBuilder:
                  (context, index) {

                final mensagem =
                    mensagens[index];

                final enviadaPorMim =
                    mensagem['sender_id']
                    == user!.id;

                return Align(

                  alignment:

                      enviadaPorMim

                      ? Alignment.centerRight

                      : Alignment.centerLeft,

                  child: Container(

                    margin:
                        const EdgeInsets.all(8),

                    padding:
                        const EdgeInsets.all(12),

                    decoration:
                        BoxDecoration(

                      color:

                          enviadaPorMim

                          ? Colors.deepPurple

                          : Colors.grey[300],

                      borderRadius:
                          BorderRadius.circular(12),
                    ),

                    child: Text(

                      mensagem['mensagem'],

                      style: TextStyle(

                        color:

                            enviadaPorMim

                            ? Colors.white

                            : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding:
                const EdgeInsets.all(12),

            child: Row(
              children: [

                Expanded(

                  child: TextField(
                    controller:
                        controller,

                    decoration:
                        const InputDecoration(
                      hintText:
                          'Digite uma mensagem',
                    ),
                  ),
                ),

                IconButton(
                  onPressed:
                      enviarMensagem,

                  icon:
                      const Icon(Icons.send),
                ),

              ],
            ),
          ),

        ],
      ),
    );
  }
}