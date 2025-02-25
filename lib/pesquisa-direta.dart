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

  void _fetchMusic() async {
  FirebaseFirestore.instance.collection('musica').get().then((snapshot) {
    List<Map<String, String>> musicList = snapshot.docs.map((doc) {
      return {
        'music': _formatName((doc['track_name'] ?? 'Desconhecido').toString()),
        'artist': _formatName((doc['artist_name'] ?? 'Desconhecido').toString()),
      };
    }).toList();

    setState(() {
      _allMusicList = musicList;
      _filteredMusicList = List.from(musicList);
    });
  }).catchError((error) {
    print("Erro ao carregar músicas: $error");
  });
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
                            builder: (context) => const TelaInicialScreen(),
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: Text(
                        'Buscar Músicas',
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
                            vertical: 8, horizontal: 20),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.music_note,
                            color: Color(0xFFF14621),
                            size: 30,
                          ),
                          title: Text(
                            musicItem['music']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            musicItem['artist']!,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
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