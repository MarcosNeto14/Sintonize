import 'package:flutter/material.dart';
import 'usuario.dart'; // Importe a tela de usuário
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AlterarDadosScreen extends StatefulWidget {
  const AlterarDadosScreen({super.key});

  @override
  State<AlterarDadosScreen> createState() => _AlterarDadosScreenState();
}

class _AlterarDadosScreenState extends State<AlterarDadosScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _dataNascController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _senhaAtualController = TextEditingController();

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não autenticado.')),
      );
      return;
    }

    if (_senhaAtualController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha sua senha atual.')),
      );
      return;
    }

    try {
      // Reautenticar o usuário para verificar a senha atual
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _senhaAtualController.text,
      );
      await user.reauthenticateWithCredential(credential);

      // Atualizar os dados do Firebase
      final updates = <String, dynamic>{};
      if (_nomeController.text.isNotEmpty) {
        updates['nome'] = _nomeController.text;
      }
      if (_dataNascController.text.isNotEmpty) {
        updates['data_nasc'] = _dataNascController.text;
      }
      if (_emailController.text.isNotEmpty) {
        await user.updateEmail(_emailController.text);
        updates['email'] = _emailController.text;
      }
      if (_senhaController.text.isNotEmpty) {
        await user.updatePassword(_senhaController.text);
      }

      if (updates.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .update(updates);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados atualizados com sucesso!')),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'wrong-password':
          message = 'Senha atual incorreta.';
          break;
        case 'email-already-in-use':
          message = 'O e-mail informado já está em uso.';
          break;
        case 'weak-password':
          message = 'A nova senha é muito fraca.';
          break;
        default:
          message = 'Erro ao atualizar dados.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro inesperado.')),
      );
    }
  }

  String? _validateDate(String? value) {
    if (value != null && value.isNotEmpty) {
      final parts = value.split('/');
      if (parts.length != 3) return 'Formato inválido (dd/mm/aaaa)';
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day == null || month == null || year == null) return 'Data inválida';
      if (day < 1 || day > 31 || month < 1 || month > 12) {
        return 'Data inválida';
      }
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value != null && value.isNotEmpty) {
      const emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
      if (!RegExp(emailRegex).hasMatch(value)) {
        return 'Formato de e-mail inválido';
      }
    }
    return null;
  }

  void _formatDate(String value) {
    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
    String formatted = digitsOnly;
    if (digitsOnly.length > 2) {
      formatted = '${digitsOnly.substring(0, 2)}/${digitsOnly.substring(2)}';
    }
    if (digitsOnly.length > 4) {
      formatted =
          '${digitsOnly.substring(0, 2)}/${digitsOnly.substring(2, 4)}/${digitsOnly.substring(4)}';
    }
    if (formatted.length > 10) {
      formatted = formatted.substring(0, 10);
    }
    _dataNascController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    _buildField('Nome', _nomeController),
                    const SizedBox(height: 20),
                    _buildField(
                        'Data de Nascimento (dd/mm/aaaa)', _dataNascController,
                        keyboardType: TextInputType.number,
                        onChanged: _formatDate,
                        validator: _validateDate),
                    const SizedBox(height: 20),
                    _buildField('E-mail', _emailController,
                        validator: _validateEmail),
                    const SizedBox(height: 20),
                    _buildField('Senha Atual', _senhaAtualController,
                        obscureText: true),
                    const SizedBox(height: 20),
                    _buildField('Nova Senha (Opcional)', _senhaController,
                        obscureText: true),
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF14621),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Salvar Alterações',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Botão de retorno para a tela de usuário
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
                      builder: (context) => const UsuarioScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {bool obscureText = false,
      TextInputType keyboardType = TextInputType.text,
      void Function(String)? onChanged,
      String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.black, fontSize: 18),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.yellow[900],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
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
