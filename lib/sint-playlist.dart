import 'package:flutter/material.dart';
import 'sintonizados.dart';

class PlaylistScreen extends StatelessWidget {
  final String nome;
  final String musica;
  final String localizacao;

  const PlaylistScreen({
    super.key,
    required this.nome,
    required this.musica,
    required this.localizacao,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1E1C1),
      body: Column(
        children: [
          // Cabeçalho com logo e botão "home"
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
                        builder: (context) => const SintonizadosScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Título "Playlists de {nome}"
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Playlists de $nome',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const Divider(thickness: 1),
          // Corpo da página
          Expanded(
            child: Column(
              children: [
                // Informações do usuário
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nome,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '🎵 Música favorita: $musica',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '📍 Localização: $localizacao',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(thickness: 1),
                const SizedBox(height: 10),
                // Título "Playlists"
                const Text(
                  'Playlists',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildPlaylistCard('Favoritas'),
                      _buildPlaylistCard('Pop Hits'),
                      _buildPlaylistCard('Clássicos do Rock'),
                      _buildPlaylistCard('Brasileiras'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistCard(String title) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: const Color(0xFFF14621),
      elevation: 4,
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: const Icon(Icons.music_note, color: Colors.white),
        onTap: () {
          // Implementar ação ao clicar na playlist
        },
      ),
    );
  }
}
