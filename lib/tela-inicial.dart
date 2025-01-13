import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'usuario.dart';
import 'pesquisa-direta.dart';
import 'pagina-artista.dart';

class TelaInicialScreen extends StatefulWidget {
  const TelaInicialScreen({super.key});

  @override
  _TelaInicialScreenState createState() => _TelaInicialScreenState();
}

class _TelaInicialScreenState extends State<TelaInicialScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<String> fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      if (docSnapshot.exists) {
        return docSnapshot.data()?['nome'] ?? 'Usuário';
      }
    }
    return 'Usuário';
  }

  Future<Map<String, String>> fetchMusica() async {
    final musicas = await FirebaseFirestore.instance.collection('musica').get();

    if (musicas.docs.isNotEmpty) {
      final musica = musicas.docs.first; // Pega a primeira música, mas você pode randomizar aqui
      return {
        'nome': musica['nome'] ?? 'Sem Título',
        'artista': musica['artista'] ?? 'Desconhecido',
      };
    }

    return {
      'titulo': 'Sem Título',
      'artista': 'Desconhecido',
    };
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background com animação
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: DynamicBackgroundPainter(_controller.value),
                child: SizedBox.expand(),
              );
            },
          ),
          // Conteúdo da tela
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
                          Icons.music_note,
                          color: Colors.white,
                          size: 50,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FutureBuilder<String>(
                            future: fetchUserName(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Text(
                                  'Carregando...',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }

                              if (snapshot.hasError) {
                                return const Text(
                                  'Erro ao carregar',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }

                              return Text(
                                '${snapshot.data?.toUpperCase()}, ESSA MÚSICA É A SUA CARA, QUE TAL SINTONIZAR?',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Image.asset(
                'assets/logo-sintoniza.png',
                width: 180,
                height: 180,
              ),
              const SizedBox(height: 20),
              FutureBuilder<Map<String, String>>(
              future: fetchMusica(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // Indicador de carregamento
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return const Text(
                    'Erro ao carregar música',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontFamily: 'Piazzolla',
                    ),
                  );
                }

                final musica = snapshot.data!;
                return Column(
                  children: [
                    Text(
                      musica['titulo']!,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 24,
                        fontFamily: 'Piazzolla',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      musica['artista']!,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 18,
                        fontFamily: 'Piazzolla',
                      ),
                    ),
                  ],
                );
              },
            ),

              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ArtistaScreen(
                                    artistaNome: 'Bruno Mars')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF14621),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          shadowColor: Colors.black.withOpacity(0.9),
                          elevation: 5,
                        ),
                        child: const Text(
                          'Ir ao Artista',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const PesquisaDiretaScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF14621),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          shadowColor: Colors.black.withOpacity(0.3),
                          elevation: 5,
                        ),
                        child: const Text(
                          'Pesquisa Direta',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
          Positioned(
            top: 30,
            right: 30,
            child: IconButton(
              icon: const Icon(Icons.person, color: Colors.white, size: 60),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UsuarioScreen(),
                  ),
                );
              },
            ),
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
