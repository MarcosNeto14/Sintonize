import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
        });
      } catch (e) {
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
      });
    } catch (e) {
      print("Erro ao carregar músicas disponíveis: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  'assets/logo-sintoniza.png',
                  width: 70,
                  height: 70,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      'Bem-vindo(a), $userName!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.home, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TelaInicialScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person, color: Colors.white, size: 60),
              const SizedBox(width: 10),
              Text(
                userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AlterarDadosScreen()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 30),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                children: [
                  _buildMenuButton('Criar Playlist', Icons.add, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CriarPlaylistScreen(
                                editPlaylist: {},
                              )),
                    ).then((_) => _fetchPlaylists());
                  }),
                  const SizedBox(height: 20),
                  if (playlists.isNotEmpty)
                    ...playlists.map((playlist) {
                      final playlistData =
                          playlist.data() as Map<String, dynamic>;
                      final name = playlistData['nome'] ?? 'Sem nome';
                      final musicas = playlistData['musicas'] ?? [];
                      final musicCount = musicas.length;

                      return ListTile(
                        title: Text(
                          name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          '$musicCount músicas',
                          style: const TextStyle(color: Colors.white54),
                        ),
                        tileColor: Colors.grey[800],
                        onTap: () {
                          _showPlaylistDetails(
                              context, playlist.id, playlistData, musicas);
                        },
                      );
                    }).toList()
                  else
                    const Center(
                      child: Text(
                        'Você ainda não criou nenhuma playlist.',
                        style: TextStyle(color: Colors.white),
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
      Map<String, dynamic> playlistData, List musicas) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFE1E1C1), // Cor de fundo do pop-up
          title: Text(
            playlistData['nome'] ?? 'Playlist sem nome',
            style: const TextStyle(
              color: Colors.black, // Cor do título
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...musicas.map((musica) {
                return FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('musica')
                      .where('track_name', isEqualTo: musica)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    if (snapshot.hasError) {
                      return const Text('Erro ao carregar músicas');
                    }

                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      final artistName =
                          snapshot.data!.docs.first['artist_name'] ??
                              'Desconhecido';

                      return ListTile(
                        title: Text(
                          '$musica - $artistName',
                          style: const TextStyle(color: Colors.black),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await _deleteSongFromPlaylist(playlistId, musica);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    } else {
                      return ListTile(
                        title: Text(
                          '$musica - Artista não encontrado',
                          style: const TextStyle(color: Colors.black),
                        ),
                      );
                    }
                  },
                );
              }).toList(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _deletePlaylist(playlistId);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Excluir Playlist',
                  style:
                      TextStyle(color: Colors.white), // Cor do texto do botão
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFF14621), // Cor de fundo do botão
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _showAddSongDialog(context, playlistId);
                },
                child: const Text(
                  'Adicionar Músicas',
                  style:
                      TextStyle(color: Colors.white), // Cor do texto do botão
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFF14621), // Cor de fundo do botão (verde)
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddSongDialog(BuildContext context, String playlistId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adicionar Música'),
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FutureBuilder<QuerySnapshot>(
                    future:
                        FirebaseFirestore.instance.collection('musica').get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      if (snapshot.hasError) {
                        return const Text('Erro ao carregar músicas');
                      }

                      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                        return Column(
                          children: snapshot.data!.docs.map((doc) {
                            final trackName = doc['track_name'];
                            final artistName =
                                doc['artist_name'] ?? 'Desconhecido';

                            return ListTile(
                              title: Text('$trackName - $artistName'),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.add, color: Colors.green),
                                onPressed: () {
                                  _addSongToPlaylist(playlistId, trackName);
                                  Navigator.pop(context);
                                },
                              ),
                            );
                          }).toList(),
                        );
                      } else {
                        return const Text('Nenhuma música disponível');
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _addSongToPlaylist(String playlistId, String song) async {
    try {
      final playlistRef =
          FirebaseFirestore.instance.collection('playlists').doc(playlistId);
      final playlistDoc = await playlistRef.get();
      if (playlistDoc.exists) {
        List<dynamic> musicas = playlistDoc['musicas'] ?? [];
        if (!musicas.contains(song)) {
          musicas.add(song);
          await playlistRef.update({
            'musicas': musicas,
          });
          setState(() {
            _fetchPlaylists();
          });
        }
      }
    } catch (e) {
      print("Erro ao adicionar música: $e");
    }
  }

  Future<void> _deleteSongFromPlaylist(String playlistId, String song) async {
    try {
      final playlistRef =
          FirebaseFirestore.instance.collection('playlists').doc(playlistId);
      final playlistDoc = await playlistRef.get();
      if (playlistDoc.exists) {
        List<dynamic> musicas = playlistDoc['musicas'] ?? [];
        musicas.remove(song);

        await playlistRef.update({
          'musicas': musicas,
        });

        setState(() {
          _fetchPlaylists();
        });
      }
    } catch (e) {
      print("Erro ao excluir música: $e");
    }
  }

  Future<void> _deletePlaylist(String playlistId) async {
    try {
      final playlistRef =
          FirebaseFirestore.instance.collection('playlists').doc(playlistId);
      await playlistRef.delete();

      setState(() {
        _fetchPlaylists();
      });
    } catch (e) {
      print("Erro ao excluir playlist: $e");
    }
  }

  Widget _buildMenuButton(String title, IconData icon, VoidCallback onTap,
      {bool isExitButton = false}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isExitButton ? Colors.red : Colors.orange,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
      onPressed: onTap,
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
