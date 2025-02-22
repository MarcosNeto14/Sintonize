import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdicionarMusicaScreen extends StatefulWidget {
  final String playlistId;
  final List<String> currentSongs;

  const AdicionarMusicaScreen({
    required this.playlistId,
    required this.currentSongs,
    super.key,
  });

  @override
  _AdicionarMusicaScreenState createState() => _AdicionarMusicaScreenState();
}

class _AdicionarMusicaScreenState extends State<AdicionarMusicaScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _musicasDataset = [];
  List<DocumentSnapshot> _musicasFiltradas = [];
  List<String> _musicasSelecionadas = [];

  @override
  void initState() {
    super.initState();
    _fetchMusicas();
    _searchController.addListener(_filterMusicas);
  }

  Future<void> _fetchMusicas() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('musica').get();
      setState(() {
        _musicasDataset = snapshot.docs.where((musica) {
          return !widget.currentSongs.contains(musica['track_name']);
        }).toList();
        _musicasFiltradas = _musicasDataset;
      });
    } catch (e) {
      print("Erro ao buscar músicas: $e");
    }
  }

  void _filterMusicas() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _musicasFiltradas = _musicasDataset.where((musica) {
        String musicaNome = musica['track_name'].toLowerCase();
        String artistName = musica['artist_name']?.toLowerCase() ?? '';
        return musicaNome.contains(query) || artistName.contains(query);
      }).toList();
    });
  }

  String _formatName(String name) {
    if (name.isEmpty) return name;
    return name.split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
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
                        Navigator.pop(context);
                      },
                    ),
                    Expanded(
                      child: Text(
                        'Adicionar Músicas',
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Pesquisar Música ou Artista',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _musicasFiltradas.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _musicasFiltradas.length,
                      itemBuilder: (context, index) {
                        var musica = _musicasFiltradas[index];
                        String musicaNome = _formatName(musica['track_name']);
                        String artistName = _formatName(musica['artist_name'] ?? 'Desconhecido');

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            title: Text('$musicaNome - $artistName'),
                            trailing: IconButton(
                              icon: Icon(
                                _musicasSelecionadas.contains(musica['track_name'])
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                color: const Color(0xFFF14621),
                              ),
                              onPressed: () {
                                setState(() {
                                  if (_musicasSelecionadas.contains(musica['track_name'])) {
                                    _musicasSelecionadas.remove(musica['track_name']);
                                  } else {
                                    _musicasSelecionadas.add(musica['track_name']);
                                  }
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: ElevatedButton(
              onPressed: () async {
                if (_musicasSelecionadas.isNotEmpty) {
                  try {
                    final playlistRef = FirebaseFirestore.instance
                        .collection('playlists')
                        .doc(widget.playlistId);

                    await playlistRef.update({
                      'musicas': FieldValue.arrayUnion(_musicasSelecionadas),
                    });

                    Navigator.pop(context, _musicasSelecionadas);
                  } catch (e) {
                    print("Erro ao adicionar músicas: $e");
                  }
                } else {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF14621),
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Concluir',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}