import 'package:flutter/material.dart';
import 'tela-inicial.dart';
import 'barra_de_pesquisa.dart';

class PesquisaDiretaScreen extends StatefulWidget {
  const PesquisaDiretaScreen({super.key});

  @override
  _PesquisaDiretaScreenState createState() => _PesquisaDiretaScreenState();
}

class _PesquisaDiretaScreenState extends State<PesquisaDiretaScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, String>> _musicList = [
    {'music': 'Just the Way You Are', 'artist': 'Bruno Mars'},
    {'music': 'Treasure', 'artist': 'Bruno Mars'},
    {'music': 'With You', 'artist': 'Chris Brown'},
    {'music': 'Forever', 'artist': 'Chris Brown'},
  ];

  List<Map<String, String>> _filteredMusicList = [];

  @override
  void initState() {
    super.initState();
    _filteredMusicList = List.from(_musicList);
  }

  void _filterMusicList(String query) {
    setState(() {
      _filteredMusicList = _musicList.where((musicItem) {
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
      backgroundColor: const Color(0xFFE1E1C1),
      body: Column(
        children: [
          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  'assets/logo-sintoniza.png',
                  width: 80,
                  height: 80,
                ),
                IconButton(
                  icon: const Icon(Icons.home, color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TelaInicialScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          BarraDePesquisa(
            controller: _searchController,
            hintText: 'Pesquise por artista ou música...',
            onChanged: _filterMusicList,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredMusicList.length,
              itemBuilder: (context, index) {
                final musicItem = _filteredMusicList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 20),
                  color: const Color(0xFFE1E1C1),
                  child: ListTile(
                    title: Text(
                      musicItem['music']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(musicItem['artist']!),
                    trailing: IconButton(
                      icon: const Icon(Icons.arrow_forward, color: Colors.white),
                      color: const Color(0xFFF14621),
                      onPressed: () {
                        // Implementar ação ao clicar no item
                      },
                    ),
                    tileColor: const Color(0xFFF14621),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
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
