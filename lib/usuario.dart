import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sintonize/detalhesplaylist.dart';
import 'tela-inicial.dart';
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
  int _selectedIndex = 0;
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
          if (userData != null && userData.containsKey('nome')) {
            setState(() {
              userName = userData['nome'];
            });
          } else {
            setState(() {
              userName = 'Usuário';
            });
          }
        } else {
          setState(() {
            userName = 'Usuário não encontrado';
          });
        }
      } catch (e) {
        setState(() {
          userName = 'Erro ao carregar usuário';
        });
        print("Erro ao carregar nome do usuário: $e");
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
      backgroundColor: Colors.white,
      body: Column(
        children: [
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
                    const Icon(Icons.person, color: Colors.white, size: 50),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                children: [
                  _buildMenuItem('Criar Playlist', Icons.add, () {
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
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFF9E80),
              Color(0xFFF14621),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          currentIndex: _selectedIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.edit),
              label: 'Alterar Dados',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.exit_to_app),
              label: 'Sair da Conta',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.delete),
              label: 'Excluir Conta',
            ),
          ],
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });

            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            } else if (index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AlterarDadosScreen()),
              );
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ExcluirContaScreen()),
              );
            }
          },
          iconSize: 30, // Ajusta o tamanho dos ícones
          selectedLabelStyle: const TextStyle(
              fontSize: 12), // Ajusta o tamanho do texto do label
          unselectedLabelStyle: const TextStyle(
              fontSize: 12), // Ajusta o tamanho do texto não selecionado
          elevation: 0, // Remove a sombra da barra inferior
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: const Color(0xFFF14621)),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontFamily: 'Piazzolla',
              ),
            ),
          ],
        ),
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
}