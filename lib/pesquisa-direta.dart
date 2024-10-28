import 'package:flutter/material.dart';

class PesquisaDiretaScreen extends StatelessWidget {
  const PesquisaDiretaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1E1C1), 
      body: Column(
        children: [
          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/logo-sintoniza.png',
                  width: 80,
                  height: 80,
                ),
              ],
            ),
          ),
          // Nome da tela centralizado
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              'Pesquisa Direta',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Offside',
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Campo de pesquisa
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.black, // Campo de pesquisa preto
                hintText: 'Pesquise por artista ou música...',
                hintStyle: const TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          // Lista de músicas
          Expanded(
            child: ListView(
              children: [
                _buildMusicItem('Just the Way You Are', 'Bruno Mars', context),
                _buildMusicItem('Treasure', 'Bruno Mars', context),
                _buildMusicItem('With You', 'Chris Brown', context),
                _buildMusicItem('Forever', 'Chris Brown', context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMusicItem(String music, String artist, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      color: const Color(0xFFE1E1C1), // Fundo do item
      child: ListTile(
        title: Text(
          music,
          style: const TextStyle(
            fontWeight: FontWeight.bold, // Nome da música em negrito
          ),
        ),
        subtitle: Text(artist),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward, color: Colors.white),
          color: const Color(0xFFF14621), // Cor do botão
          onPressed: () {
            // Ação ao pressionar o botão
            // Adicione aqui a lógica para tocar a música ou redirecionar para a tela de detalhes
          },
        ),
        tileColor: const Color(0xFFF14621), // Cor do tile
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
