import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AlterarDadosScreen extends StatefulWidget {
  const AlterarDadosScreen({super.key});

  @override
  State<AlterarDadosScreen> createState() => _AlterarDadosScreenState();
}

class _AlterarDadosScreenState extends State<AlterarDadosScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _senhaAtualController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  // Carrega os dados do usuário ao iniciar a tela
  Future<void> _carregarDadosUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          setState(() {
            _nomeController.text = userData?['nome'] ?? '';
            _emailController.text = user.email ?? '';
            _isLoading = false;
          });
        }
      } catch (e) {
        print("Erro ao carregar dados do usuário: $e");
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
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

  String? _validateEmail(String? value) {
    if (value != null && value.isNotEmpty) {
      const emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
      if (!RegExp(emailRegex).hasMatch(value)) {
        return 'Formato de e-mail inválido';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fundo branco
      body: Column(
        children: [
          // Barra superior com logo e botão de voltar
          Container(
            color: const Color(0xFFF14621),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.pop(context); // Volta para a tela anterior
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
          const SizedBox(height: 20),
          // Formulário de alteração de dados
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else ...[
                      _buildField('Nome', _nomeController),
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {bool obscureText = false, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.grey),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
