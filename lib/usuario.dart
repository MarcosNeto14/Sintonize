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

class _UsuarioScreenState extends State<UsuarioScreen>
    with SingleTickerProviderStateMixin {
  String userName = 'Carregando...';
  final User? user = FirebaseAuth.instance.currentUser;
  List<DocumentSnapshot> playlists = [];
  List<DocumentSnapshot> availableSongs = [];
  bool isLoadingPlaylists = true;
  bool isLoadingSongs = true;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchPlaylists();
    _fetchAvailableSongs();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
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
                      borderRadius: BorderRadius.circular(20)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF9E80), Color(0xFFF14621)],
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
                                borderRadius: BorderRadius.circular(15)),
                            child: ListTile(
                              title: Text(name,
                                  style: const TextStyle(
                                      color: Colors.black87,
                                      fontFamily: 'Piazzolla',
                                      fontSize: 18)),
                              subtitle: Text('$musicCount músicas',
                                  style: const TextStyle(
                                      color: Colors.black54,
                                      fontFamily: 'Piazzolla',
                                      fontSize: 14)),
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
                                    fontSize: 18))),
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
            top: 35,
            right: 30,
            child: IconButton(
              icon: const Icon(Icons.home, color: Colors.white, size: 50),
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

  void _showPlaylistDetails(BuildContext context, String playlistId,
      Map<String, dynamic> playlistData, List<dynamic> musicas) {
    // Converte a lista de músicas para List<String>
    final List<String> musicasList = List<String>.from(musicas);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalhesPlaylistScreen(
          playlistId: playlistId,
          playlistData: playlistData,
          musicas: musicasList, // Passando a lista de músicas convertida
        ),
      ),
    );
  }

  Widget _buildMenuButton(String title, IconData icon, VoidCallback onPressed,
      {bool isExitButton = false}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: isExitButton
            ? Colors.red
            : const Color.fromARGB(255, 255, 255, 255),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 24),
      label: Text(title, style: const TextStyle(fontSize: 16)),
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
        path.quadraticBezierTo(x + waveWidth / 4, size.height / 2 - waveHeight,
            x + waveWidth / 2, size.height / 2);
        path.quadraticBezierTo(x + waveWidth * 3 / 4,
            size.height / 2 + waveHeight, x + waveWidth, size.height / 2);
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
