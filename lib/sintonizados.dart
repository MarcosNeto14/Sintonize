import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'usuario.dart';
import 'perfil-sintonizado.dart';

class SintonizadosScreen extends StatefulWidget {
  const SintonizadosScreen({super.key});

  @override
  _SintonizadosScreenState createState() => _SintonizadosScreenState();
}

class _SintonizadosScreenState extends State<SintonizadosScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<DocumentSnapshot> _sintonizados = [];
  List<DocumentSnapshot> _allUsers = [];
  final User? user = FirebaseAuth.instance.currentUser;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _fetchSintonizados();
    _fetchAllUsers();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: DynamicBackgroundPainter(_controller.value),
                child: SizedBox.expand(),
              );
            },
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: Image.asset(
                      'assets/logo-sintoniza.png',
                      width: 100,
                      height: 100,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Pesquisar Sintonizados',
                      filled: true,
                      fillColor: Colors.yellow[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      hintStyle: const TextStyle(color: Colors.white),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Sintonizados',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
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
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: const Color(0xFFF14621),
                        elevation: 4,
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundImage:
                                AssetImage('assets/logo-sintoniza.png'),
                            radius: 30,
                          ),
                          title: Text(
                            user['nome'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white),
                            onPressed: () {
                              _removerSintonizado(user.id);
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
                      color: Colors.red,
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
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: const Color(0xFFF14621),
                        elevation: 4,
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundImage:
                                AssetImage('assets/logo-sintoniza.png'),
                            radius: 30,
                          ),
                          title: Text(
                            user['nome'],
                            style: const TextStyle(
                              fontSize: 18,
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
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 30,
            right: 30,
            child: IconButton(
              icon: const Icon(Icons.person,
                  color: Color.fromARGB(255, 0, 0, 0), size: 30),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UsuarioScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DynamicBackgroundPainter extends CustomPainter {
  final double animationValue;

  DynamicBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF14621).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final waveHeight = 50;
    final waveWidth = size.width / 2;

    for (int i = 0; i < 3; i++) {
      double shift = animationValue * size.width * 0.5 * (i + 1);
      Path path = Path();
      path.moveTo(-shift, size.height);
      path.lineTo(-shift, size.height / 2);

      for (double x = -shift; x < size.width + waveWidth; x += waveWidth) {
        path.quadraticBezierTo(
          x + waveWidth / 4,
          size.height / 2 - waveHeight,
          x + waveWidth / 2,
          size.height / 2,
        );
        path.quadraticBezierTo(
          x + waveWidth * 3 / 4,
          size.height / 2 + waveHeight,
          x + waveWidth,
          size.height / 2,
        );
      }

      path.lineTo(size.width + shift, size.height);
      path.close();

      canvas.drawPath(path, paint);
      paint.color = paint.color.withOpacity(0.2);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
