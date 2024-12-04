import 'package:flutter/material.dart';

class SintonizadosScreen extends StatelessWidget {
  const SintonizadosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lista simulada de postagens
    final List<Map<String, String>> posts = [
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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sintonizados',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Ação de busca futura
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFE1E1C1),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
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
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '🎵 ${post['musica']}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '📍 ${post['localizacao']}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
