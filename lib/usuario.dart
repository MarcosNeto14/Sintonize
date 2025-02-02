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

class _UsuarioScreenState extends State<UsuarioScreen>
    with SingleTickerProviderStateMixin {
  String userName = 'Carregando...';
  final User? user = FirebaseAuth.instance.currentUser;
  List<DocumentSnapshot> playlists = [];
  List<DocumentSnapshot> availableSongs = [];

  // Adicionando o AnimationController
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchPlaylists();
    _fetchAvailableSongs();

    // Inicializando o AnimationController
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    // Dispose do AnimationController para evitar vazamentos de memória
    _controller.dispose();
    super.dispose();
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
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: DynamicBackgroundPainter(_controller.value),
                child: SizedBox.expand(),
              );
            },
          ),
          Column(
            children: [
              const SizedBox(height: 20),
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
                        const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 50,
                        ),
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
                                _showPlaylistDetails(context, playlist.id,
                                    playlistData, musicas);
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
          Positioned(
            top: 30,
            right: 30,
            child: IconButton(
              icon: const Icon(Icons.home, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TelaInicialScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddSongDialog(BuildContext context, String playlistId) {
    final TextEditingController _songController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Adicionar Música',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _songController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Música',
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Poppins',
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final songName = _songController.text.trim();
                  if (songName.isNotEmpty) {
                    await _addSongToPlaylist(playlistId, songName);
                    Navigator.pop(
                        context); // Fecha o diálogo de adicionar música
                    // Atualiza o popup da playlist para refletir a nova música
                    _showPlaylistDetails(context, playlistId, {}, [songName]);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Por favor, insira o nome da música.'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF14621),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Adicionar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPlaylistDetails(BuildContext context, String playlistId,
      Map<String, dynamic> playlistData, List musicas) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                playlistData['nome'] ?? 'Playlist sem nome',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...musicas.map((musica) {
                      return FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('musica')
                            .where('track_name', isEqualTo: musica)
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }

                          if (snapshot.hasError) {
                            return const Text(
                              'Erro ao carregar músicas',
                              style: TextStyle(color: Colors.black),
                            );
                          }

                          if (snapshot.hasData &&
                              snapshot.data!.docs.isNotEmpty) {
                            final artistName =
                                snapshot.data!.docs.first['artist_name'] ??
                                    'Desconhecido';

                            return ListTile(
                              title: Text(
                                '$musica - $artistName',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  bool confirm = await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Confirmar Exclusão'),
                                        content: Text(
                                            'Deseja excluir a música $musica da playlist?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text('Excluir'),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirm == true) {
                                    await _deleteSongFromPlaylist(
                                        playlistId, musica);
                                    setState(() {
                                      musicas.remove(musica);
                                    });
                                  }
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
                        bool confirm = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirmar Exclusão'),
                              content: const Text(
                                  'Deseja excluir esta playlist permanentemente?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Excluir'),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirm == true) {
                          await _deletePlaylist(playlistId);
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Excluir Playlist',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _showAddSongDialog(context, playlistId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF14621),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Adicionar Músicas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15),
        shadowColor: Colors.black.withOpacity(0.3),
        elevation: 5,
      ),
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
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

class DynamicBackgroundPainter extends CustomPainter {
  final double animationValue;

  DynamicBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF14621).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final waveHeight = 50;
    final waveWidth = size.width / 2;

    for (int i = 0; i < 3; i++) {
      double shift = animationValue * size.width * 0.5 * (i + 1);
      Path path = Path();
      path.moveTo(-shift, size.height);
      path.lineTo(-shift, size.height / 2);

      for (double x = -shift; x < size.width + waveWidth; x += waveWidth) {
        path.quadraticBezierTo(
          x + waveWidth / 4,
          size.height / 2 - waveHeight,
          x + waveWidth / 2,
          size.height / 2,
        );
        path.quadraticBezierTo(
          x + waveWidth * 3 / 4,
          size.height / 2 + waveHeight,
          x + waveWidth,
          size.height / 2,
        );
      }

      path.lineTo(size.width + shift, size.height);
      path.close();

      canvas.drawPath(path, paint);
      paint.color = paint.color.withOpacity(0.2);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
