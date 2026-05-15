// Geovanna Kaori Shimada e Jamile Franquilim de Oliveira

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/login.dart';
import 'screens/cadastro.dart';
import 'screens/criar_post.dart';
import 'screens/perfil.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vaergkiaivwwiwhnsxlw.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZhZXJna2lhaXZ3d2l3aG5zeGx3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg0OTcwNDgsImV4cCI6MjA5NDA3MzA0OH0.qB-YhxKi9KpNWG5xE6Fv7ZG9UqaHu3LxL_PeJBoHeO0',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      title: 'Rede Social',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
      ),

      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() =>
      _MyHomePageState();
}

class _MyHomePageState
    extends State<MyHomePage> {

  List posts = [];

  Map<String, dynamic>? profile;

  bool carregando = true;

  bool mostrarNotificacoes = false;

  int notificacoes = 3;

  @override
  void initState() {

    super.initState();

    carregarDados();

    Supabase.instance.client.auth
        .onAuthStateChange
        .listen((data) {

      carregarDados();
    });
  }

  Future<void> carregarDados() async {

    try {

      final user =
          Supabase.instance.client.auth.currentUser;

      final postsResponse =
          await Supabase.instance.client
          .from('posts')
          .select('''
            *,
            profiles (
              nome,
              foto_perfil
            )
          ''')
          .order(
            'created_at',
            ascending: false,
          );

      if (user != null) {

        final profileResponse =
            await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        profile = profileResponse;
      }

      setState(() {

        posts = postsResponse;

        carregando = false;
      });

    } catch (e) {

      print(e);

      setState(() {

        carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    final user =
        Supabase.instance.client.auth.currentUser;

    if (carregando) {

      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(

      body: Stack(
        children: [

          Row(
            children: [

              Container(
                width: 250,
                color: Colors.white,

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    const SizedBox(height: 30),

                    Padding(
                      padding: const EdgeInsets.all(16),

                      child: Image.asset(
                        'assets/imagens/kamilelogo.png',
                        height: 50,
                      ),
                    ),

                    navItem(
                      Icons.home,
                      'Página inicial',
                      () {},
                    ),

                    navItem(
                      Icons.messenger_outline,
                      'Mensagens',
                      () {},
                    ),

                    if (user != null)

                      navItemNotificacao(
                        Icons.favorite_border,
                        'Notificações',
                        notificacoes,
                        () {

                          setState(() {

                            mostrarNotificacoes =
                                !mostrarNotificacoes;
                          });
                        },
                      ),

                    if (user != null) ...[

                      navItem(
                        Icons.add_box_outlined,
                        'Criar',
                        () async {

                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const CriarPostPage(),
                            ),
                          );

                          carregarDados();
                        },
                      ),

                      navItem(
                        Icons.account_circle_outlined,
                        'Perfil',
                        () {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const PerfilPage(),
                            ),
                          );
                        },
                      ),

                    ] else ...[

                      navButton(
                        'Login',
                        () {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const MyLoginPage(
                                title: 'Login',
                              ),
                            ),
                          );
                        },
                      ),

                      navButton(
                        'Cadastro',
                        () {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const MyCadastroPage(
                                title: 'Cadastro',
                              ),
                            ),
                          );
                        },
                      ),

                    ],

                    const Spacer(),

                    // PERFIL
                    if (user != null)

                      Padding(
                        padding: const EdgeInsets.all(20),

                        child: Row(
                          children: [

                            CircleAvatar(

                              radius: 20,

                              backgroundImage:

                                  profile != null &&
                                  profile!['foto_perfil'] !=
                                      null &&
                                  profile!['foto_perfil']
                                      .toString()
                                      .isNotEmpty

                                  ? NetworkImage(
                                      profile![
                                          'foto_perfil'],
                                    )

                                  : null,

                              child:

                                  profile == null ||
                                  profile![
                                          'foto_perfil'] ==
                                      null ||
                                  profile![
                                          'foto_perfil']
                                      .toString()
                                      .isEmpty

                                  ? const Icon(
                                      Icons.person,
                                    )

                                  : null,
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                profile?['nome'] ?? '',
                                overflow:
                                    TextOverflow.ellipsis,
                              ),
                            ),

                          ],
                        ),
                      ),

                  ],
                ),
              ),

              // FEED
              Expanded(
                child: Container(

                  color: Colors.grey[100],

                  child: Center(
                    child: SizedBox(

                      width: 500,

                      child: posts.isEmpty

                      ? const Center(
                          child: Text(
                            'Nenhuma postagem ainda',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        )

                      : ListView.builder(

                          itemCount: posts.length,

                          itemBuilder:
                              (context, index) {

                            return Padding(
                              padding:
                                  const EdgeInsets.only(
                                top: 30,
                              ),

                              child:
                                  post(posts[index]),
                            );
                          },
                        ),
                    ),
                  ),
                ),
              ),

              // LADO DIREITO
              Container(
                width: 300,
                color: Colors.white,
              ),

            ],
          ),

          // PAINEL NOTIFICAÇÕES
          if (mostrarNotificacoes)

            Positioned(

              left: 250,

              top: 0,
              bottom: 0,

              child: Container(

                width: 400,

                decoration: const BoxDecoration(

                  color: Colors.white,

                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),

                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      color: Colors.black12,
                    ),
                  ],
                ),

                child: Column(
                  children: [

                    const SizedBox(height: 40),

                    const Padding(
                      padding: EdgeInsets.all(20),

                      child: Align(
                        alignment: Alignment.centerLeft,

                        child: Text(
                          'Notificações',

                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child: ListView.builder(

                        itemCount: notificacoes,

                        itemBuilder:
                            (context, index) {

                          return ListTile(

                            leading:
                                const CircleAvatar(
                              child:
                                  Icon(Icons.person),
                            ),

                            title: Text(
                              'Usuário $index curtiu sua postagem',
                            ),

                            subtitle:
                                const Text(
                              'Agora mesmo',
                            ),
                          );
                        },
                      ),
                    ),

                  ],
                ),
              ),
            ),

        ],
      ),
    );
  }

  // NAV ITEM NORMAL
  Widget navItem(
    IconData icon,
    String texto,
    VoidCallback onTap,
  ) {

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 5,
      ),

      child: InkWell(

        borderRadius:
            BorderRadius.circular(12),

        onTap: onTap,

        child: Padding(
          padding: const EdgeInsets.all(12),

          child: Row(
            children: [

              Icon(icon, size: 28),

              const SizedBox(width: 15),

              Text(
                texto,

                style: const TextStyle(
                  fontSize: 18,
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  // NAV ITEM COM BADGE
  Widget navItemNotificacao(
    IconData icon,
    String texto,
    int quantidade,
    VoidCallback onTap,
  ) {

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 5,
      ),

      child: InkWell(

        borderRadius:
            BorderRadius.circular(12),

        onTap: onTap,

        child: Padding(
          padding: const EdgeInsets.all(12),

          child: Row(
            children: [

              Stack(
                clipBehavior: Clip.none,

                children: [

                  Icon(icon, size: 28),

                  if (quantidade > 0)

                    Positioned(

                      right: -8,
                      top: -8,

                      child: Container(

                        padding:
                            const EdgeInsets.all(5),

                        decoration:
                            const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),

                        child: Text(
                          quantidade.toString(),

                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                ],
              ),

              const SizedBox(width: 15),

              Text(
                texto,

                style: const TextStyle(
                  fontSize: 18,
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  // BOTÃO LOGIN/CADASTRO
  Widget navButton(
    String texto,
    VoidCallback onTap,
  ) {

    return Padding(
      padding: const EdgeInsets.all(12),

      child: SizedBox(

        width: double.infinity,

        child: ElevatedButton(
          onPressed: onTap,
          child: Text(texto),
        ),
      ),
    );
  }

  // POST
  Widget post(Map postData) {

    final profileData =
        postData['profiles'];

    final username =
        profileData != null
        ? profileData['nome'] ?? ''
        : '';

    final foto =
        profileData != null
        ? profileData['foto_perfil']
        : null;

    final conteudo =
        postData['conteudo'];

    return Container(

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(12),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Padding(
            padding: const EdgeInsets.all(12),

            child: Row(
              children: [

                CircleAvatar(

                  radius: 18,

                  backgroundImage:

                      foto != null &&
                      foto.toString().isNotEmpty

                      ? NetworkImage(foto)

                      : null,

                  child:

                      foto == null ||
                      foto.toString().isEmpty

                      ? const Icon(Icons.person)

                      : null,
                ),

                const SizedBox(width: 10),

                Text(
                  username,

                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

              ],
            ),
          ),

          if (postData['imagem'] != null &&
              postData['imagem']
                  .toString()
                  .isNotEmpty)

            Image.network(
              postData['imagem'],
              fit: BoxFit.cover,
            ),

          Padding(
            padding: const EdgeInsets.all(16),

            child: Text(conteudo ?? ''),
          ),

        ],
      ),
    );
  }
}