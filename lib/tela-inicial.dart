import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'usuario.dart';
import 'pesquisa-direta.dart';
import 'sintonizados.dart';
import 'dart:math';

class TelaInicialScreen extends StatefulWidget {
  const TelaInicialScreen({super.key});

  @override
  _TelaInicialScreenState createState() => _TelaInicialScreenState();
}

class _TelaInicialScreenState extends State<TelaInicialScreen> {
  int _selectedIndex = 0;

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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return {'track_name': 'Erro', 'artist_name': 'Usuário não autenticado'};
    }

    try {
      final userRef =
          FirebaseFirestore.instance.collection('usuarios').doc(user.uid);
      final userDoc = await userRef.get();

      // Obtém os gêneros favoritos do usuário
      final List<dynamic> generosFavoritosRaw =
          userDoc.data()?['generos_favoritos'] ?? [];

      // Normaliza os gêneros para letras minúsculas
      final List<String> generosFavoritos =
          generosFavoritosRaw.map((g) => g.toString().toLowerCase()).toList();

      if (generosFavoritos.isEmpty) {
        return {
          'track_name': 'Nenhum gênero favorito',
          'artist_name': 'Selecione gêneros'
        };
      }

      final DateTime now = DateTime.now();
      final String todayKey = "${now.year}-${now.month}-${now.day}";

      Map<String, dynamic> userHistory =
          userDoc.data()?['historico_musicas'] ?? {};

      // Se já recomendou uma música hoje, retorna a mesma
      if (userHistory.containsKey(todayKey)) {
        final Map<String, dynamic> todayMusic = userHistory[todayKey];
        return {
          'track_name': todayMusic['track_name'] as String? ?? 'Sem título',
          'artist_name': todayMusic['artist_name'] as String? ?? 'Desconhecido'
        };
      }

      // Consulta músicas que pertencem aos gêneros favoritos do usuário
      final QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('musica').get();

      // Filtra músicas que pertencem aos gêneros favoritos
      final availableMusics = querySnapshot.docs.where((doc) {
        final String genre = doc['genre'].toString().toLowerCase();
        return generosFavoritos.contains(genre);
      }).toList();

      if (availableMusics.isEmpty) {
        return {'track_name': 'Nenhuma música disponível', 'artist_name': ''};
      }

      final random = Random();

      // Remove músicas já recomendadas anteriormente
      final filteredMusics = availableMusics
          .where((doc) => !userHistory.values.any((music) =>
              music['track_name'] == doc['track_name'] &&
              music['artist_name'] == doc['artist_name']))
          .toList();

      if (filteredMusics.isEmpty) {
        return {
          'track_name': 'Todas músicas já foram sugeridas',
          'artist_name': ''
        };
      }

      // Escolhe uma música aleatória da lista filtrada
      final randomMusic = filteredMusics[random.nextInt(filteredMusics.length)];
      final musicData = {
        'track_name': randomMusic['track_name'] as String? ?? 'Sem título',
        'artist_name': randomMusic['artist_name'] as String? ?? 'Desconhecido'
      };

      // Armazena a música do dia no histórico
      userHistory[todayKey] = musicData;
      await userRef.update({'historico_musicas': userHistory});

      return musicData;
    } catch (e) {
      return {'track_name': 'Erro ao carregar música', 'artist_name': 'Erro'};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
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
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
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
                return Card(
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
                          Color(0xFFFF9E80), // Laranja claro
                          Color(0xFFF14621), // Laranja escuro
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          musica['track_name']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontFamily: 'Piazzolla',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          musica['artist_name']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'Piazzolla',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const Spacer(),
          ],
        ),
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
              icon: Icon(Icons.search),
              label: 'Pesquisa Direta',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.music_note),
              label: 'Sintonizados',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Minha Conta',
            ),
          ],
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });

            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SintonizadosScreen()),
              );
            } else if (index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PesquisaDiretaScreen()),
              );
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UsuarioScreen()),
              );
            }
          },
          iconSize: 30,
          selectedLabelStyle: const TextStyle(fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
