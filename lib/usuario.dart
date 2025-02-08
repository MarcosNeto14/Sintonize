import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sintonize/detalhesplaylist.dart';
import 'tela-inicial.dart';
import 'sintonizados.dart';
import 'main.dart';
import 'excluir-conta.dart';
import 'alterar-dados.dart';
import 'criar_playlist.dart';

class UsuarioScreen extends StatefulWidget {
  const UsuarioScreen({super.key});

  @override
  State<UsuarioScreen> createState() => _UsuarioScreenState();
}

class _UsuarioScreenState extends State<UsuarioScreen> {
  String userName = 'Carregando...';
  final User? user = FirebaseAuth.instance.currentUser;
  List<DocumentSnapshot> playlists = [];
  List<DocumentSnapshot> availableSongs = [];
  bool isLoadingPlaylists = true;
  bool isLoadingSongs = true;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchPlaylists();
    _fetchAvailableSongs();
  }

  Future<void> _fetchUserName() async {
    if (user != null) {
      try {
        final DocumentSnapshot<Map<String, dynamic>> userDoc =
            await FirebaseFirestore.instance
                .collection('usuarios')
                .doc(user!.uid)
                .get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          setState(() {
            userName = userData?['nome'] ?? 'Usuário';
          });
        }
      } catch (e) {
        setState(() {
          userName = 'Erro ao carregar usuário';
        });
      }
    } else {
      setState(() {
        userName = 'Usuário não autenticado';
      });
    }
  }

  Future<void> _fetchPlaylists() async {
    if (user != null) {
      try {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('playlists')
            .where('userId', isEqualTo: user!.uid)
            .get();

        setState(() {
          playlists = snapshot.docs;
          isLoadingPlaylists = false;
        });
      } catch (e) {
        setState(() {
          isLoadingPlaylists = false;
        });
        print("Erro ao carregar playlists: $e");
      }
    }
  }

  Future<void> _fetchAvailableSongs() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('musica').get();

      setState(() {
        availableSongs = snapshot.docs;
        isLoadingSongs = false;
      });
    } catch (e) {
      setState(() {
        isLoadingSongs = false;
      });
      print("Erro ao carregar músicas disponíveis: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fundo branco
      body: Column(
        children: [
          // Barra superior com logo e botão de voltar
          Container(
            color: const Color(0xFFF14621),
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 10), // Reduzido o padding vertical
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TelaInicialScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 10), // Espaço entre o ícone e o logo
                Image.asset(
                  'assets/logo-sintoniza.png',
                  width: 60, // Reduzido o tamanho do logo
                  height: 60,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Card de boas-vindas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 15,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF9E80),
                      Color(0xFFF14621),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.white, size: 50),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Bem-vindo(a), $userName!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Lista de opções e playlists
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                children: [
                  _buildMenuButton('Criar Playlist', Icons.add, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              CriarPlaylistScreen(editPlaylist: {})),
                    ).then((_) => _fetchPlaylists());
                  }),
                  const SizedBox(height: 20),
                  if (isLoadingPlaylists)
                    const Center(child: CircularProgressIndicator())
                  else if (playlists.isNotEmpty)
                    ...playlists.map((playlist) {
                      final playlistData =
                          playlist.data() as Map<String, dynamic>;
                      final name = playlistData['nome'] ?? 'Sem nome';
                      final musicas = playlistData['musicas'] ?? [];
                      final musicCount = musicas.length;

                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          title: Text(
                            name,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontFamily: 'Piazzolla',
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text(
                            '$musicCount músicas',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontFamily: 'Piazzolla',
                              fontSize: 14,
                            ),
                          ),
                          tileColor: Colors.white,
                          onTap: () {
                            _showPlaylistDetails(
                                context, playlist.id, playlistData, musicas);
                          },
                        ),
                      );
                    }).toList()
                  else
                    const Center(
                      child: Text(
                        'Você ainda não criou nenhuma playlist.',
                        style: TextStyle(
                          color: Colors.orange,
                          fontFamily: 'Piazzolla',
                          fontSize: 18,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  _buildMenuButton('Sintonizados', Icons.music_note, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SintonizadosScreen()),
                    );
                  }),
                  const SizedBox(height: 15),
                  _buildMenuButton('Alterar Dados', Icons.edit, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AlterarDadosScreen()),
                    );
                  }),
                  const SizedBox(height: 15),
                  _buildMenuButton('Sair da Conta', Icons.exit_to_app, () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()),
                    );
                  }, isExitButton: true),
                  const SizedBox(height: 15),
                  _buildMenuButton('Excluir Conta', Icons.delete, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ExcluirContaScreen()),
                    );
                  }, isExitButton: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPlaylistDetails(BuildContext context, String playlistId,
      Map<String, dynamic> playlistData, List<dynamic> musicas) async {
    final List<String> musicasList = List<String>.from(musicas);

    // Aguarda o retorno da tela de detalhes da playlist
    final playlistExcluida = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalhesPlaylistScreen(
          playlistId: playlistId,
          playlistData: playlistData,
          musicas: musicasList,
        ),
      ),
    );

    // Se a playlist foi excluída, recarrega a lista de playlists
    if (playlistExcluida == true) {
      _fetchPlaylists();
    }
  }

  Widget _buildMenuButton(String title, IconData icon, VoidCallback onPressed,
      {bool isExitButton = false}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: isExitButton
            ? Colors.red
            : const Color(0xFFF14621), // Cor laranja para botões
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 24, color: Colors.white),
      label: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
  }
}
