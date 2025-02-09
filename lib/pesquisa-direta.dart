import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tela-inicial.dart';

class PesquisaDiretaScreen extends StatefulWidget {
  const PesquisaDiretaScreen({super.key});

  @override
  _PesquisaDiretaScreenState createState() => _PesquisaDiretaScreenState();
}

class _PesquisaDiretaScreenState extends State<PesquisaDiretaScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _allMusicList = [];
  List<Map<String, String>> _filteredMusicList = [];

  @override
  void initState() {
    super.initState();
    _fetchMusic();
  }

  // Função para buscar músicas do Firestore
  void _fetchMusic() async {
    FirebaseFirestore.instance.collection('musica').get().then((snapshot) {
      List<Map<String, String>> musicList = snapshot.docs.map((doc) {
        return {
          'music': (doc['track_name'] ?? 'Desconhecido').toString(),
          'artist': (doc['artist_name'] ?? 'Desconhecido').toString(),
        };
      }).toList();

      setState(() {
        _allMusicList = musicList;
        _filteredMusicList = List.from(musicList);
      });
    });
  }

  // Função para filtrar as músicas conforme o usuário digita
  void _filterMusicList(String query) {
    setState(() {
      _filteredMusicList = _allMusicList.where((musicItem) {
        final music = musicItem['music']!.toLowerCase();
        final artist = musicItem['artist']!.toLowerCase();
        return music.contains(query.toLowerCase()) ||
            artist.contains(query.toLowerCase());
      }).toList();
    });
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
          // Barra de pesquisa
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Pesquise por artista ou música...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 20,
                  ),
                ),
                onChanged: _filterMusicList,
              ),
            ),
          ),
          // Lista de músicas
          Expanded(
            child: _filteredMusicList.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhuma música encontrada.',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 18,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredMusicList.length,
                    itemBuilder: (context, index) {
                      final musicItem = _filteredMusicList[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFF14621),
                                Color(0xFFFF9E80),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.music_note,
                              color: Colors.white,
                              size: 40,
                            ),
                            title: Text(
                              musicItem['music']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              musicItem['artist']!,
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.arrow_forward,
                                  color: Colors.white),
                              onPressed: () {
                                // Implementar ação ao clicar no item
                              },
                            ),
                          ),
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
