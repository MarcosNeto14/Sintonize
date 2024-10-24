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
      backgroundColor: Colors.black, 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/logo-sintoniza.png', 
              width: 400, 
              height: 400,
            ),
            const SizedBox(height: 50), 

            // Botão de Login
            SizedBox(
              width: 200, 
              height: 50, 
              child: ElevatedButton(
                onPressed: () {
                  
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF14621), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), 
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 18,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20), 

            // Botão de Cadastro
            SizedBox(
              width: 200, 
              height: 50, 
              child: ElevatedButton(
                onPressed: () {
                  
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF14621), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), 
                  ),
                ),
                child: const Text(
                  'Cadastro',
                  style: TextStyle(
                    color: Colors.white, 
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
