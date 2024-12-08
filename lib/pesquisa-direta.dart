import 'package:flutter/material.dart';
import 'tela-inicial.dart';

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
    _filteredMusicList =
        List.from(_musicList); // Inicialmente, todos os itens são exibidos.
    _searchController.addListener(_filterMusicList);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterMusicList);
    _searchController.dispose();
    super.dispose();
  }

  void _filterMusicList() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMusicList = _musicList.where((musicItem) {
        final music = musicItem['music']!.toLowerCase();
        final artist = musicItem['artist']!.toLowerCase();
        return music.contains(query) || artist.contains(query);
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
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              'Pesquisa Direta',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Offside',
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.black,
                hintText: 'Pesquise por artista ou música...',
                hintStyle: const TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredMusicList.length,
              itemBuilder: (context, index) {
                final musicItem = _filteredMusicList[index];
                return _buildMusicItem(
                    musicItem['music']!, musicItem['artist']!, context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMusicItem(String music, String artist, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      color: const Color(0xFFE1E1C1),
      child: ListTile(
        title: Text(
          music,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(artist),
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
  }
}
