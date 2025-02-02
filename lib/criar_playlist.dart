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
  final TextEditingController _searchController =
      TextEditingController(); // Controller de busca
  List<String> _musicasSelecionadas = []; // Músicas selecionadas pelo usuário
  List<DocumentSnapshot> _musicasDataset = []; // Músicas do dataset
  List<DocumentSnapshot> _musicasFiltradas =
      []; // Músicas filtradas com base na busca
  String? _playlistName;

  @override
  void initState() {
    super.initState();
    _fetchMusicas(); // Puxa as músicas do Firestore
    _searchController.addListener(
        _filterMusicas); // Adiciona o listener para a pesquisa em tempo real
  }

  Future<void> _fetchMusicas() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('musica').get();
      setState(() {
        _musicasDataset = snapshot.docs;
        _musicasFiltradas =
            _musicasDataset; // Inicializa a lista filtrada com todas as músicas
      });
    } catch (e) {
      print("Erro ao buscar músicas: $e");
    }
  }

  // Função de filtro de músicas
  void _filterMusicas() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _musicasFiltradas = _musicasDataset.where((musica) {
        String musicaNome = musica['track_name'].toLowerCase();
        String artistName = musica['artist_name']?.toLowerCase() ?? '';
        return musicaNome.contains(query) ||
            artistName
                .contains(query); // Filtra pelo nome da música ou do artista
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Playlist'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome da Playlist'),
              onChanged: (value) {
                setState(() {
                  _playlistName = value;
                });
              },
            ),
            const SizedBox(height: 20),
            // Barra de pesquisa
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Pesquisar Música ou Artista',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 20),
            // Exibe a lista de músicas filtradas
            Expanded(
              // Use Expanded para evitar overflow
              child: _musicasFiltradas.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _musicasFiltradas.length,
                      itemBuilder: (context, index) {
                        var musica = _musicasFiltradas[index];
                        String musicaNome = musica['track_name'];
                        String artistName =
                            musica['artist_name'] ?? 'Desconhecido';

                        return ListTile(
                          title: Text(
                              '$musicaNome - $artistName'), // Exibe o nome da música e do artista
                          trailing: IconButton(
                            icon: Icon(
                              _musicasSelecionadas.contains(musicaNome)
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              color: Colors.orange,
                            ),
                            onPressed: () {
                              setState(() {
                                if (_musicasSelecionadas.contains(musicaNome)) {
                                  _musicasSelecionadas.remove(musicaNome);
                                } else {
                                  _musicasSelecionadas.add(musicaNome);
                                }
                              });
                            },
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
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
              child: const Text('Salvar Playlist'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _salvarPlaylist() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Cria um documento na coleção 'playlists' com as músicas selecionadas
        await FirebaseFirestore.instance.collection('playlists').add({
          'userId': user.uid,
          'nome': _playlistName,
          'musicas': _musicasSelecionadas, // Lista de músicas na playlist
          'dataCriacao': Timestamp.now(),
        });

        // Depois de salvar, pode retornar ou mostrar um sucesso
        Navigator.pop(context); // Volta para a tela anterior
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar a playlist: $e')),
        );
      }
    }
  }
}
