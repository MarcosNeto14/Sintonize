import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  void initState() {
    super.initState();
    _musicas = List.from(widget.musicas);
  }

  Future<void> _deleteSongFromPlaylist(String song) async {
    try {
      final playlistRef = FirebaseFirestore.instance
          .collection('playlists')
          .doc(widget.playlistId);
      final playlistDoc = await playlistRef.get();

      if (playlistDoc.exists) {
        List<dynamic> musicas = playlistDoc['musicas'] ?? [];
        musicas.remove(song);

        await playlistRef.update({
          'musicas': musicas,
        });

        setState(() {
          _musicas.remove(song);
        });
      }
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

      Navigator.pop(context);
    } catch (e) {
      print("Erro ao excluir playlist: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playlistData['nome'] ?? 'Playlist sem nome'),
      ),
      body: Column(
        children: [
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
                      return const CircularProgressIndicator();
                    }

                    if (snapshot.hasError) {
                      return const Text(
                        'Erro ao carregar músicas',
                        style: TextStyle(color: Colors.black),
                      );
                    }

                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      final artistName =
                          snapshot.data!.docs.first['artist_name'] ??
                              'Desconhecido';
                      return ListTile(
                        title: Text(
                          '$musica - $artistName',
                          style: const TextStyle(color: Colors.black),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            bool confirm = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Confirmar Exclusão'),
                                  content: Text(
                                      'Deseja excluir a música $musica da playlist?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Excluir'),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirm == true) {
                              await _deleteSongFromPlaylist(musica);
                            }
                          },
                        ),
                      );
                    } else {
                      return ListTile(
                        title: Text('$musica - Artista não encontrado'),
                      );
                    }
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _deletePlaylist,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Excluir Playlist',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
