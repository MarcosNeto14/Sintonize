import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddMusicScreen extends StatefulWidget {
  @override
  _AddMusicScreenState createState() => _AddMusicScreenState();
}

class _AddMusicScreenState extends State<AddMusicScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _artistNameController = TextEditingController();
  final TextEditingController _trackNameController = TextEditingController();
  final TextEditingController _releaseDateController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();

  Future<void> _addMusic() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('musica').add({
          'artist_name': _artistNameController.text,
          'track_name': _trackNameController.text,
          'release_date': _releaseDateController.text,
          'genre': _genreController.text,
          'topic': _topicController.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Música adicionada com sucesso!')),
        );
        _formKey.currentState!.reset();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar música: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Música'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _artistNameController,
                decoration: InputDecoration(labelText: 'artist_name'),
                validator: (value) =>
                    value!.isEmpty ? 'Digite o nome do artista' : null,
              ),
              TextFormField(
                controller: _trackNameController,
                decoration: InputDecoration(labelText: 'track_name'),
                validator: (value) =>
                    value!.isEmpty ? 'Digite o nome da música' : null,
              ),
              TextFormField(
                controller: _releaseDateController,
                decoration: InputDecoration(labelText: 'release_date'),
                keyboardType: TextInputType.datetime,
                validator: (value) =>
                    value!.isEmpty ? 'Digite a data de lançamento' : null,
              ),
              TextFormField(
                controller: _genreController,
                decoration: InputDecoration(labelText: 'genre'),
                validator: (value) =>
                    value!.isEmpty ? 'Digite o gênero da música' : null,
              ),
              TextFormField(
                controller: _topicController,
                decoration: InputDecoration(labelText: 'topic'),
                validator: (value) =>
                    value!.isEmpty ? 'Digite o tema da música' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addMusic,
                child: Text('Adicionar Música'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
