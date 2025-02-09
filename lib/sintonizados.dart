import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'perfil-sintonizado.dart';
import 'tela-inicial.dart'; // Importe a tela inicial para o botão de voltar

class SintonizadosScreen extends StatefulWidget {
  const SintonizadosScreen({super.key});

  @override
  _SintonizadosScreenState createState() => _SintonizadosScreenState();
}

class _SintonizadosScreenState extends State<SintonizadosScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<DocumentSnapshot> _sintonizados = [];
  List<DocumentSnapshot> _allUsers = [];
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _fetchSintonizados();
    _fetchAllUsers();
  }

  Future<void> _fetchSintonizados() async {
    if (user != null) {
      try {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user!.uid)
            .collection('sintonizados')
            .get();

        setState(() {
          _sintonizados = snapshot.docs;
        });
      } catch (e) {
        print("Erro ao carregar sintonizados: $e");
      }
    }
  }

  Future<void> _fetchAllUsers() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('usuarios').get();

      setState(() {
        _allUsers = snapshot.docs;
      });
    } catch (e) {
      print("Erro ao carregar usuários: $e");
    }
  }

  Future<void> _adicionarSintonizado(String userId) async {
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(user!.uid)
              .collection('sintonizados')
              .doc(userId)
              .set({
            'nome': userDoc['nome'],
            'dataCriacao': FieldValue.serverTimestamp(),
            'userId': userId,
          });

          _fetchSintonizados();
        }
      } catch (e) {
        print("Erro ao adicionar sintonizado: $e");
      }
    }
  }

  Future<void> _removerSintonizado(String userId) async {
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user!.uid)
            .collection('sintonizados')
            .doc(userId)
            .delete();

        await _fetchSintonizados();
        await _fetchAllUsers();

        setState(() {});
      } catch (e) {
        print("Erro ao remover sintonizado: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredSintonizados = _sintonizados
        .where((user) =>
            user['nome'].toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    final filteredAllUsers = _allUsers
        .where((user) =>
            user['nome'].toLowerCase().contains(_searchQuery.toLowerCase()) &&
            !_sintonizados.any((sintonizado) => sintonizado.id == user.id))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white, // Fundo branco
      body: Column(
        children: [
          // Barra superior com logo e botão de voltar
          Container(
            color: const Color(0xFFF14621),
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 10), // Reduzido o padding vertical
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TelaInicialScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 10), // Espaço entre o ícone e o logo
                Image.asset(
                  'assets/logo-sintoniza.png',
                  width: 60, // Reduzido o tamanho do logo
                  height: 60,
                ),
              ],
            ),
          ),
          // Barra de pesquisa
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Pesquisar Sintonizados',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 20,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          ),
          // Lista de sintonizados
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    'Sintonizados',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF14621),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredSintonizados.length,
                    itemBuilder: (context, index) {
                      final user = filteredSintonizados[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFF14621),
                                Color(0xFFFF9E80),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundImage:
                                  AssetImage('assets/logo-sintoniza.png'),
                              radius: 30,
                            ),
                            title: Text(
                              user['nome'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            trailing: IconButton(
                              icon:
                                  const Icon(Icons.delete, color: Colors.white),
                              onPressed: () {
                                _removerSintonizado(user.id);
                              },
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PerfilSintonizadoScreen(
                                    userId: user.id,
                                    nome: user['nome'],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Usuários Gerais',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF14621),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredAllUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredAllUsers[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFF14621),
                                Color(0xFFFF9E80),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundImage:
                                  AssetImage('assets/logo-sintoniza.png'),
                              radius: 30,
                            ),
                            title: Text(
                              user['nome'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.add, color: Colors.white),
                              onPressed: () {
                                _adicionarSintonizado(user.id);
                              },
                            ),
                          ),
                        ),
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
}
