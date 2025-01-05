import 'package:flutter/material.dart';
import 'usuario.dart';
import 'sint-playlist.dart';
import 'barra_de_pesquisa.dart';

class SintonizadosScreen extends StatefulWidget {
  const SintonizadosScreen({super.key});

  @override
  _SintonizadosScreenState createState() => _SintonizadosScreenState();
}

class _SintonizadosScreenState extends State<SintonizadosScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, String>> _posts = [
    {
      'nome': 'Marcos',
      'musica': 'Shallow - Lady Gaga & Bradley Cooper',
      'localizacao': 'Recife, PE',
      'imagem': 'assets/logo-sintoniza.png',
    },
    {
      'nome': 'Ana',
      'musica': 'Blinding Lights - The Weeknd',
      'localizacao': 'Olinda, PE',
      'imagem': 'assets/logo-sintoniza.png',
    },
    {
      'nome': 'João',
      'musica': 'Bohemian Rhapsody - Queen',
      'localizacao': 'Paulista, PE',
      'imagem': 'assets/logo-sintoniza.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredPosts = _posts
        .where((post) =>
            post['nome']!.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

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
                  width: 70,
                  height: 70,
                ),
                IconButton(
                  icon: const Icon(Icons.home, color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UsuarioScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          BarraDePesquisa(
            controller: _searchController,
            hintText: 'Pesquisar Sintonizados',
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPosts.length,
              itemBuilder: (context, index) {
                final post = filteredPosts[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlaylistScreen(
                          nome: post['nome']!,
                          musica: post['musica']!,
                          localizacao: post['localizacao']!,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: const Color(0xFFF14621),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundImage: AssetImage(post['imagem']!),
                            radius: 30,
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post['nome']!,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '🎵 ${post['musica']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '📍 ${post['localizacao']}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
