import 'package:flutter/material.dart';

class TelaInicialScreen extends StatelessWidget {
  const TelaInicialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1E1C1), // Altere a cor de fundo aqui
      body: Column(
        children: [
          // Borda superior preta com logo, texto de boas-vindas e ícone de usuário
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo pequena no canto superior esquerdo
                Image.asset(
                  'assets/logo-sintoniza.png',
                  width: 100, // Ajuste o tamanho conforme necessário
                  height: 100,
                ),
                // Texto de boas-vindas centralizado
                const Expanded(
                  child: Text(
                    'Bem vindo(a), Usuário!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Ícone de usuário no canto superior direito
                IconButton(
                  icon: const Icon(Icons.person, color: Colors.white),
                  onPressed: () {
                    // Ação para o ícone de usuário
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Texto "Essa música é a sua cara! Que tal sintonizar?"
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'Essa música é a sua cara! Que tal sintonizar?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black, // Alterado para preto para melhor contraste
                fontSize: 18,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Image.asset(
            'assets/logo-musica.jpg', 
            width: 200, // 
            height: 200,
          ),

          const SizedBox(height: 20),

          // Nome da música
          const Text(
            'Die With a Smile',
            style: TextStyle(
              color: Colors.black, // Alterado para preto para melhor contraste
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          // Nome do artista
          const Text(
            'Lady Gaga feat. Bruno Mars',
            style: TextStyle(
              color: Colors.black54, // Alterado para um cinza escuro para melhor contraste
              fontSize: 18,
            ),
          ),

          const Spacer(),

          // Botões laranja "Ir ao Artista" e "Pesquisa Direta" lado a lado
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Botão "Ir ao Artista"
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Ação para o botão "Ir ao Artista"
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF14621), // Cor laranja
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Ir ao Artista',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Botão "Pesquisa Direta"
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Ação para o botão "Pesquisa Direta"
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF14621), // Cor laranja
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Pesquisa Direta',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
