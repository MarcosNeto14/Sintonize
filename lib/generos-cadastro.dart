import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tela-inicial.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GenerosCadastroScreen extends StatefulWidget {
  const GenerosCadastroScreen({super.key});

  @override
  _GenerosCadastroScreenState createState() => _GenerosCadastroScreenState();
}

class _GenerosCadastroScreenState extends State<GenerosCadastroScreen> {
  final List<String> generos = [
    'Rock',
    'Pop',
    'Jazz',
    'Blues',
    'Sertanejo',
    'Hip-Hop',
    'Eletrônica',
    'Clássica',
    'Reggae',
    'MPB'
  ];
  final Map<String, bool> selecionados = {};

  @override
  void initState() {
    super.initState();
    for (var genero in generos) {
      selecionados[genero] = false;
    }
  }

  Future<void> _salvarGeneros() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final generosSelecionados = selecionados.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();

        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .update({
          'generos_favoritos': generosSelecionados,
        });

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TelaInicialScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao salvar os gêneros!')),
        );
      }
    }
  }

  void _confirmar() {
    if (selecionados.values.contains(true)) {
      _salvarGeneros();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Selecione pelo menos um gênero musical!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Image.asset(
                'assets/logo-sintoniza.png',
                width: 100,
                height: 100,
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Offside',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: generos.length,
                itemBuilder: (context, index) {
                  final genero = generos[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          genero,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontFamily: 'Offside',
                          ),
                        ),
                        Switch(
                          value: selecionados[genero]!,
                          activeColor: const Color(0xFFF14621),
                          inactiveThumbColor:
                              const Color.fromARGB(255, 170, 172, 44),
                          onChanged: (bool isSelected) {
                            setState(() {
                              selecionados[genero] = isSelected;
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF14621),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Confirmar',
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
