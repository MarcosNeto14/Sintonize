import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'sintonizados.dart';

class PerfilSintonizadoScreen extends StatefulWidget {
  final String userId;
  final String nome;

  const PerfilSintonizadoScreen({
    super.key,
    required this.userId,
    required this.nome,
  });

  @override
  _PerfilSintonizadoScreenState createState() =>
      _PerfilSintonizadoScreenState();
}

class _PerfilSintonizadoScreenState extends State<PerfilSintonizadoScreen> {
  String _musica = 'Carregando...';
  String _artista = 'Carregando...';
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _fetchMusicaRecomendada();
  }

  // Função para formatar nomes com iniciais maiúsculas
  String _formatName(String name) {
    if (name.isEmpty) return name;
    return name.split(' ').map((word) {
      if (word.isNotEmpty) {
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      }
      return word;
    }).join(' ');
  }

  Future<void> _fetchMusicaRecomendada() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        final historicoMusicas = userDoc.data()?['historico_musicas'] ?? {};
        if (historicoMusicas.isNotEmpty) {
          final ultimaMusicaKey = historicoMusicas.keys.last;
          final ultimaMusica = historicoMusicas[ultimaMusicaKey];
          setState(() {
            _musica = _formatName(ultimaMusica['track_name'] ?? 'Sem título');
            _artista = _formatName(ultimaMusica['artist_name'] ?? 'Desconhecido');
          });
        } else {
          setState(() {
            _musica = 'Nenhuma música recomendada ainda';
            _artista = '';
          });
        }
      }
    } catch (e) {
      print("Erro ao carregar música recomendada: $e");
      setState(() {
        _musica = 'Erro ao carregar música';
        _artista = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Cabeçalho com estilo da tela de usuário
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                            builder: (context) => const SintonizadosScreen(),
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: Text(
                        'Sintonizado',
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
          // Corpo da tela
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Image.asset(
                      'assets/logo-sintoniza.png',
                      height: 100,
                      width: 100,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Perfil de ${widget.nome}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF14621),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
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
                        child: Column(
                          children: [
                            Text(
                              '🎵 $_musica',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Artista: $_artista',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}