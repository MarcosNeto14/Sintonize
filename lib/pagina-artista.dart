import 'package:flutter/material.dart';
import 'tela-inicial.dart';

class ArtistaScreen extends StatelessWidget {
  final String artistaNome; // Nome do artista a ser exibido

  const ArtistaScreen({super.key, required this.artistaNome});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1E1C1), // Fundo da tela
      body: Column(
        children: [
          // Barra superior preta com logo, título do artista e botão "Home"
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
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildMusicItem('Just the Way You Are', context),
                _buildMusicItem('Treasure', context),
                _buildMusicItem('Locked Out of Heaven', context),
                _buildMusicItem('24K Magic', context),
                _buildMusicItem('Grenade', context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMusicItem(String music, BuildContext context) {
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
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward, color: Colors.white),
          color: const Color(0xFFF14621),
          onPressed: () {
            // Ação ao clicar no item de música
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
