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
  List<String> _generosFavoritos = [];
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _fetchMusicaRecomendada();
    _fetchGenerosFavoritos();
  }

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
            _artista =
                _formatName(ultimaMusica['artist_name'] ?? 'Desconhecido');
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

  Future<void> _fetchGenerosFavoritos() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        final generosFavoritosRaw =
            userDoc.data()?['generos_favoritos'] as List<dynamic>?;
        if (generosFavoritosRaw != null) {
          final generosFavoritos =
              generosFavoritosRaw.map((g) => g.toString()).toList();
          setState(() {
            _generosFavoritos = generosFavoritos;
          });
        }
      }
    } catch (e) {
      print("Erro ao carregar gêneros favoritos: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
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
                        'Perfil de ${widget.nome}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 40, //
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
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
          ),
          if (_generosFavoritos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
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
                    crossAxisAlignment:
                        CrossAxisAlignment.center, 
                    children: [
                      const Text(
                        'Gêneros Favoritos',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        alignment: WrapAlignment.center, 
                        spacing: 8,
                        children: _generosFavoritos.map((genero) {
                          return Chip(
                            label: Text(
                              genero,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: const Color(0xFFF14621),
                          );
                        }).toList(),
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
