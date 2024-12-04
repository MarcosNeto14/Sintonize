import 'package:flutter/material.dart';

class SintonizadosScreen extends StatefulWidget {
  const SintonizadosScreen({super.key});

  @override
  _SintonizadosScreenState createState() => _SintonizadosScreenState();
}

class _SintonizadosScreenState extends State<SintonizadosScreen> {
  // Lista simulada de postagens com cidades de Pernambuco e comentários
  final List<Map<String, dynamic>> posts = [
    {
      'nome': 'Marcos',
      'musica': 'Shallow - Lady Gaga & Bradley Cooper',
      'localizacao': 'Recife, Pernambuco',
      'comentario': 'Essa música me emociona toda vez que escuto!',
      'imagem': 'assets/logo-sintoniza.png', // Ícone do logo
      'curtidas': 5,
      'comentarios': [
        'Amo demais!',
        'Perfeita!',
      ],
      'curtido': false, // Flag para verificar se foi curtido
    },
    {
      'nome': 'Ana',
      'musica': 'Blinding Lights - The Weeknd',
      'localizacao': 'Olinda, Pernambuco',
      'comentario': 'Não consigo parar de ouvir, é viciante!',
      'imagem': 'assets/logo-sintoniza.png', // Ícone do logo
      'curtidas': 3,
      'comentarios': [
        'Essa música é tudo!',
      ],
      'curtido': false, // Flag para verificar se foi curtido
    },
    {
      'nome': 'João',
      'musica': 'Bohemian Rhapsody - Queen',
      'localizacao': 'Caruaru, Pernambuco',
      'comentario': 'Clássico! Nunca canso de ouvir.',
      'imagem': 'assets/logo-sintoniza.png', // Ícone do logo
      'curtidas': 8,
      'comentarios': [
        'Top demais!',
        'Impossível não gostar!',
      ],
      'curtido': false, // Flag para verificar se foi curtido
    },
    {
      'nome': 'Maria',
      'musica': 'Viva La Vida - Coldplay',
      'localizacao': 'Petrolina, Pernambuco',
      'comentario': 'Uma música que sempre traz boas lembranças!',
      'imagem': 'assets/logo-sintoniza.png', // Ícone do logo
      'curtidas': 10,
      'comentarios': [
        'Maravilhosa!',
      ],
      'curtido': false, // Flag para verificar se foi curtido
    },
    {
      'nome': 'Carlos',
      'musica': 'Rolling in the Deep - Adele',
      'localizacao': 'Jaboatão dos Guararapes, Pernambuco',
      'comentario': 'A voz dela é incrível! Me arrepia sempre.',
      'imagem': 'assets/logo-sintoniza.png', // Ícone do logo
      'curtidas': 6,
      'comentarios': [
        'Amo Adele!',
      ],
      'curtido': false, // Flag para verificar se foi curtido
    },
  ];

  void _curtirPost(int index) {
    setState(() {
      // Se já foi curtido, desfaz o curtir (diminui as curtidas)
      if (posts[index]['curtido']) {
        posts[index]['curtidas']--;
        posts[index]['curtido'] = false;
      } else {
        // Se não foi curtido, aumenta as curtidas
        posts[index]['curtidas']++;
        posts[index]['curtido'] = true;
      }
    });
  }

  void _adicionarComentario(int index, String comentario) {
    setState(() {
      posts[index]['comentarios'].add(comentario);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sintonizados',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Ação de busca futura
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFE1E1C1),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header da postagem
                  Row(
                    children: [
                      Image.asset(
                        post['imagem']!, // Logo como ícone
                        width: 60,
                        height: 60,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post['nome']!,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '🎵 ${post['musica']}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '📍 ${post['localizacao']}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Comentário principal
                  Text(
                    '💬 Comentário: ${post['comentario']}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Curtir e comentar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Botão de curtir
                      IconButton(
                        icon: Icon(
                          post['curtido'] ? Icons.thumb_up : Icons.thumb_up_off_alt,
                          color: post['curtido'] ? Colors.blue : Colors.grey,
                        ),
                        onPressed: () {
                          _curtirPost(index);
                        },
                      ),
                      Text('${post['curtidas']} Curtidas'),
                      const SizedBox(width: 20),
                      // Botão de comentar
                      IconButton(
                        icon: const Icon(Icons.comment, color: Colors.grey),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              TextEditingController _comentarioController =
                                  TextEditingController();
                              return AlertDialog(
                                title: const Text('Adicionar Comentário'),
                                content: TextField(
                                  controller: _comentarioController,
                                  decoration: const InputDecoration(
                                    hintText: 'Escreva seu comentário...',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      _adicionarComentario(
                                          index, _comentarioController.text);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Adicionar'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Cancelar'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      Text('${post['comentarios'].length} Comentários'),
                    ],
                  ),
                  // Exibir comentários adicionais
                  const SizedBox(height: 10),
                  for (var comentario in post['comentarios'])
                    Padding(
                      padding: const EdgeInsets.only(left: 40),
                      child: Text(
                        '💬 $comentario',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
