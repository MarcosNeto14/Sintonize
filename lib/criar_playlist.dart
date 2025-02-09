import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CriarPlaylistScreen extends StatefulWidget {
  const CriarPlaylistScreen(
      {super.key, required Map<String, dynamic> editPlaylist});

  @override
  _CriarPlaylistScreenState createState() => _CriarPlaylistScreenState();
}

class _CriarPlaylistScreenState extends State<CriarPlaylistScreen> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<String> _musicasSelecionadas = [];
  List<DocumentSnapshot> _musicasDataset = [];
  List<DocumentSnapshot> _musicasFiltradas = [];
  String? _playlistName;

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
        _musicasDataset = snapshot.docs;
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
          // Campo de nome da playlist
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _nomeController,
              decoration: InputDecoration(
                labelText: 'Nome da Playlist',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _playlistName = value;
                });
              },
            ),
          ),
          const SizedBox(height: 20),
          // Campo de pesquisa de músicas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
          const SizedBox(height: 20),
          // Lista de músicas
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _musicasFiltradas.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _musicasFiltradas.length,
                      itemBuilder: (context, index) {
                        var musica = _musicasFiltradas[index];
                        String musicaNome = musica['track_name'];
                        String artistName =
                            musica['artist_name'] ?? 'Desconhecido';

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
                                _musicasSelecionadas.contains(musicaNome)
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                color: const Color(0xFFF14621),
                              ),
                              onPressed: () {
                                setState(() {
                                  if (_musicasSelecionadas
                                      .contains(musicaNome)) {
                                    _musicasSelecionadas.remove(musicaNome);
                                  } else {
                                    _musicasSelecionadas.add(musicaNome);
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
          const SizedBox(height: 20),
          // Botão de salvar playlist
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: () {
                if (_playlistName != null && _playlistName!.isNotEmpty) {
                  _salvarPlaylist();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Nome da playlist é obrigatório')),
                  );
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
                'Salvar Playlist',
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

  Future<void> _salvarPlaylist() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('playlists').add({
          'userId': user.uid,
          'nome': _playlistName,
          'musicas': _musicasSelecionadas,
          'dataCriacao': Timestamp.now(),
        });

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar a playlist: $e')),
        );
      }
    }
  }
}
