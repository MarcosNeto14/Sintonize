import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'adicionar-musica.dart';

class DetalhesPlaylistScreen extends StatefulWidget {
  final String playlistId;
  final Map<String, dynamic> playlistData;
  final List<String> musicas;

  const DetalhesPlaylistScreen({
    required this.playlistId,
    required this.playlistData,
    required this.musicas,
    super.key,
  });

  @override
  _DetalhesPlaylistScreenState createState() => _DetalhesPlaylistScreenState();
}

class _DetalhesPlaylistScreenState extends State<DetalhesPlaylistScreen> {
  late List<String> _musicas;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _musicas = List.from(widget.musicas);
    _searchController.addListener(_filterMusicas);
  }

  void _filterMusicas() {
    setState(() {
      // Filtra as músicas com base no texto da pesquisa
      _musicas = widget.musicas.where((musica) {
        return musica.toLowerCase().contains(_searchController.text.toLowerCase());
      }).toList();
    });
  }

  Future<void> _deleteSongFromPlaylist(String song) async {
    try {
      final playlistRef = FirebaseFirestore.instance
          .collection('playlists')
          .doc(widget.playlistId);
      await playlistRef.update({
        'musicas': FieldValue.arrayRemove([song]),
      });
      setState(() {
        _musicas.remove(song);
      });
    } catch (e) {
      print("Erro ao excluir música: $e");
    }
  }

  Future<void> _deletePlaylist() async {
    try {
      final playlistRef = FirebaseFirestore.instance
          .collection('playlists')
          .doc(widget.playlistId);
      await playlistRef.delete();

      Navigator.pop(context, true);
    } catch (e) {
      print("Erro ao excluir playlist: $e");
      Navigator.pop(context, false);
    }
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
                        Navigator.pop(context, true);
                      },
                    ),
                    Expanded(
                      child: Text(
                        widget.playlistData['nome'] ?? 'Playlist sem nome',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white, size: 30),
                      onPressed: () async {
                        final newSongs = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdicionarMusicaScreen(
                              playlistId: widget.playlistId,
                              currentSongs: _musicas,
                            ),
                          ),
                        );

                        if (newSongs != null) {
                          setState(() {
                            _musicas.addAll(newSongs);
                          });
                        }
                      },
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
                labelText: 'Pesquisar música',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _musicas.length,
              itemBuilder: (context, index) {
                final musica = _musicas[index];
                return FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('musica')
                      .where('track_name', isEqualTo: musica)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Erro ao carregar músicas',
                          style: TextStyle(color: Colors.black),
                        ),
                      );
                    }

                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      final artistName =
                          snapshot.data!.docs.first['artist_name'] ??
                              'Desconhecido';
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
                            '${_formatName(musica)} - ${_formatName(artistName)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await _deleteSongFromPlaylist(musica);
                            },
                          ),
                        ),
                      );
                    } else {
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 20),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          title: Text(
                            '${_formatName(musica)} - Artista não encontrado',
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: ElevatedButton(
              onPressed: _deletePlaylist,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Excluir Playlist',
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