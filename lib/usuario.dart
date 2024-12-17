import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'tela-inicial.dart';
import 'sintonizados.dart';
import 'main.dart';
import 'excluir-conta.dart';
import 'alterar-dados.dart';

class UsuarioScreen extends StatelessWidget {
  const UsuarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user =
        FirebaseAuth.instance.currentUser; // Obtém o usuário autenticado
    final String userName = user?.displayName ??
        'Usuário'; // Exibe o nome, ou 'Usuário' se não estiver definido

    return Scaffold(
      backgroundColor: const Color(0xFFE1E1C1),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  'assets/logo-sintoniza.png',
                  width: 70,
                  height: 70,
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      'Bem-vindo(a), Usuário!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.home, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TelaInicialScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person, color: Colors.black, size: 60),
              const SizedBox(width: 10),
              Text(
                userName, // Exibe o nome do usuário
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AlterarDadosScreen()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 30),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                children: [
                  _buildPlaylistCard('Favoritas'),
                  const SizedBox(height: 10),
                  _buildPlaylistCard('Playlist Pop'),
                  const SizedBox(height: 10),
                  _buildPlaylistCard('Playlist Rock'),
                  const SizedBox(height: 10),
                  _buildPlaylistCard('Playlist BR'),
                  const SizedBox(height: 30),
                  _buildMenuButton(
                    'Sintonizados',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SintonizadosScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildMenuButton(
                    'Sair da conta',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomeScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildMenuButton(
                    'Excluir conta',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ExcluirContaScreen()),
                      );
                    },
                  ),
                ],
              ),
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
        trailing: const Icon(Icons.playlist_play, color: Colors.white),
        onTap: () {},
      ),
    );
  }

  Widget _buildMenuButton(String title,
      {bool isExitButton = false, VoidCallback? onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isExitButton ? Colors.red : const Color(0xFFF14621),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 3,
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
