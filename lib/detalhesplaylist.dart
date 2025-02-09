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

      // Retorna true para indicar que a playlist foi excluída
      Navigator.pop(context, true);
    } catch (e) {
      print("Erro ao excluir playlist: $e");
      // Retorna false em caso de erro
      Navigator.pop(context, false);
    }
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
                    Navigator.pop(context); // Volta para a tela anterior
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
          const SizedBox(height: 20),
          // Título da playlist
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              widget.playlistData['nome'] ?? 'Playlist sem nome',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF14621),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Lista de músicas
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
                            vertical: 5, horizontal: 20),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          title: Text(
                            '$musica - $artistName',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
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
                        ),
                      );
                    } else {
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 20),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          title: Text(
                            '$musica - Artista não encontrado',
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
          const SizedBox(height: 20),
          // Botão de excluir playlist
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
