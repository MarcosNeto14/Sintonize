import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fundo preto
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Logo centralizada
            Image.asset(
              'assets/logo-sintoniza.png', // Certifique-se de adicionar a imagem na pasta assets
              width: 150, // Ajuste o tamanho da logo conforme necessário
              height: 150,
            ),
            const SizedBox(height: 50), // Espaço entre a logo e os botões

            // Botão de Login
            SizedBox(
              width: 200, // Largura do botão
              height: 50, // Altura do botão
              child: ElevatedButton(
                onPressed: () {
                  // Ação de login
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Cor laranja do botão
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Bordas arredondadas
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.white, // Texto branco
                    fontSize: 18,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20), // Espaço entre os botões

            // Botão de Cadastro
            SizedBox(
              width: 200, // Largura do botão
              height: 50, // Altura do botão
              child: ElevatedButton(
                onPressed: () {
                  // Ação de cadastro
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Cor laranja do botão
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Bordas arredondadas
                  ),
                ),
                child: const Text(
                  'Cadastro',
                  style: TextStyle(
                    color: Colors.white, // Texto branco
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
