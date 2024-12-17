import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Adicione a importação do Firebase Auth
import 'login.dart';
import 'generos-cadastro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _dataNascController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confSenhaController = TextEditingController();
  final TextEditingController _ruaController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _bairroController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController();
  final TextEditingController _cepController = TextEditingController();

  String? _estadoSelecionado;

  // Lista de siglas dos estados brasileiros
  final List<String> _estados = [
    "AC",
    "AL",
    "AP",
    "AM",
    "BA",
    "CE",
    "DF",
    "ES",
    "GO",
    "MA",
    "MT",
    "MS",
    "MG",
    "PA",
    "PB",
    "PR",
    "PE",
    "PI",
    "RJ",
    "RN",
    "RS",
    "RO",
    "RR",
    "SC",
    "SP",
    "SE",
    "TO"
  ];

  String? _validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'A data de nascimento é obrigatória';
    }

    final parts = value.split('/');
    if (parts.length != 3) {
      return 'Formato inválido. Use dd/mm/aaaa';
    }

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) {
      return 'Data inválida. Certifique-se de que todos os campos são números';
    }

    if (month < 1 || month > 12) {
      return 'Mês deve ser entre 01 e 12';
    }

    final maxDay = DateTime(year, month + 1, 0).day;
    if (day < 1 || day > maxDay) {
      return 'Dia deve ser entre 01 e $maxDay';
    }

    final date = DateTime(year, month, day);
    if (date.isAfter(DateTime.now())) {
      return 'A data não pode ser no futuro';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'O e-mail é obrigatório';
    }
    const pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    final regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'E-mail inválido';
    }
    return null;
  }

  String? _validateCEP(String? value) {
    if (value == null || value.isEmpty) {
      return 'O CEP é obrigatório';
    }
    if (value.length != 9 || !RegExp(r'^\d{5}-\d{3}$').hasMatch(value)) {
      return 'CEP inválido. Formato correto: XXXXX-XXX';
    }
    return null;
  }

  String? _validateNumero(String? value) {
    if (value == null || value.isEmpty) {
      return 'O número é obrigatório';
    }
    if (int.tryParse(value) == null) {
      return 'O número deve ser numérico';
    }
    return null;
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Criação de usuário no Firebase Auth
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _senhaController.text,
        );

        // Obtenha o UID do usuário recém-criado
        String uid = userCredential.user!.uid;

        // Adicionar dados do usuário no Firestore
        await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
          'nome': _nomeController.text,
          'data_nasc': _dataNascController.text,
          'email': _emailController.text,
          'endereco': {
            'rua': _ruaController.text,
            'numero': _numeroController.text,
            'bairro': _bairroController.text,
            'cidade': _cidadeController.text,
            'estado': _estadoSelecionado,
            'cep': _cepController.text,
          },
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const GenerosCadastroScreen(),
          ),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao cadastrar: ${e.message}")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro desconhecido: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/logo-sintoniza.png',
                  width: 400,
                  height: 400,
                ),
                const SizedBox(height: 50),
                // Nome
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nome',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _nomeController,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 16),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFE1E1C1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'O nome é obrigatório';
                          }
                          final hasInvalidCharacters =
                              RegExp(r'[^a-zA-ZÀ-ÿ\s]').hasMatch(value);
                          if (hasInvalidCharacters) {
                            return 'O nome não pode conter números ou caracteres especiais';
                          }
                          return null;
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-ZÀ-ÿ\s]')),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Data de Nascimento
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Data de Nascimento (dd/mm/aaaa)',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _dataNascController,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 16),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFE1E1C1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: _validateDate,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(8),
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            if (newValue.text.isEmpty) {
                              return TextEditingValue.empty;
                            }
                            final text = newValue.text.replaceAll('/', '');
                            String newText = '';
                            for (var i = 0; i < text.length; i++) {
                              if (i == 2 || i == 4) {
                                newText += '/';
                              }
                              newText += text[i];
                            }
                            return TextEditingValue(
                              text: newText,
                              selection: TextSelection.collapsed(
                                  offset: newText.length),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // E-mail
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'E-mail',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _emailController,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 16),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFE1E1C1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: _validateEmail,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Senha
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Senha',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _senhaController,
                        obscureText: true,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 16),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFE1E1C1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Confirmar Senha
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Confirmar Senha',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _confSenhaController,
                        obscureText: true,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 16),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFE1E1C1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value != _senhaController.text) {
                            return 'As senhas não coincidem';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Endereço
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rua',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _ruaController,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 16),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFE1E1C1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          hintText: 'Rua',
                          hintStyle: TextStyle(
                              color: const Color.fromARGB(255, 102, 102, 102)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Número
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Número',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _numeroController,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 16),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFE1E1C1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          hintText: 'Número',
                          hintStyle: TextStyle(
                              color: const Color.fromARGB(255, 102, 102, 102)),
                        ),
                        validator: _validateNumero,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Bairro
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bairro',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _bairroController,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 16),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFE1E1C1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          hintText: 'Bairro',
                          hintStyle: TextStyle(
                              color: const Color.fromARGB(255, 102, 102, 102)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Cidade
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cidade',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _cidadeController,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 16),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFE1E1C1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          hintText: 'Cidade',
                          hintStyle: TextStyle(
                              color: const Color.fromARGB(255, 102, 102, 102)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Estado
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Estado',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(height: 5),
                      DropdownButtonFormField<String>(
                        value: _estadoSelecionado,
                        items: _estados
                            .map(
                              (estado) => DropdownMenuItem<String>(
                                value: estado,
                                child: Text(estado),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _estadoSelecionado = value;
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFE1E1C1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // CEP
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CEP',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _cepController,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 16),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFE1E1C1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          hintText: 'CEP',
                          hintStyle: TextStyle(
                              color: const Color.fromARGB(255, 102, 102, 102)),
                        ),
                        validator: _validateCEP,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF14621),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Cadastrar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text(
                    'Já tem uma conta? Faça login',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
