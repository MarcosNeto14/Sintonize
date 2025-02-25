import 'package:flutter/material.dart';

class MusicasCidadeScreen extends StatelessWidget {
  final String cidade;
  final List<String> musicas;

  const MusicasCidadeScreen({
    Key? key,
    required this.cidade,
    required this.musicas,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Músicas em $cidade',
          style: const TextStyle(
            color: Colors.white, // Define a cor do texto como branco
          ),
        ),
        backgroundColor: const Color(0xFFF14621), // Cor de fundo do AppBar
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: musicas.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(
                musicas[index],
                style: const TextStyle(fontSize: 16),
              ),
            ),
          );
        },
      ),
    );
  }
}
