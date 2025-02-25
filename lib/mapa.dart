import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_webservice/geocoding.dart'; // Importe o pacote

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  _MapaScreenState createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  late GoogleMapController mapController;
  LatLng? _userLocation;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _fetchUserLocation();
    _fetchUsersLocationsAndMusic();
  }

  // Busca a localização do usuário atual
  Future<void> _fetchUserLocation() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();

        if (docSnapshot.exists) {
          final endereco = docSnapshot.data()?['endereco'];
          final cidade = endereco['cidade'];
          final estado = endereco['estado'];

          print('Buscando localização do usuário: $cidade, $estado');
          final location = await _getCoordinates(cidade, estado);
          setState(() {
            _userLocation = location;
          });
        } else {
          print('Documento do usuário não encontrado no Firestore');
        }
      } else {
        print('Usuário não autenticado');
      }
    } catch (e) {
      print('Erro ao buscar localização do usuário: $e');
    }
  }

  // Busca as localizações e músicas recomendadas de todos os usuários
  Future<void> _fetchUsersLocationsAndMusic() async {
    try {
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('usuarios').get();

      // Agrupa músicas por cidade
      final Map<String, List<String>> musicasPorCidade = {};

      for (var doc in usersSnapshot.docs) {
        final endereco = doc.data()['endereco'];
        final cidade = endereco['cidade'];
        final estado = endereco['estado'];
        final musicaRecomendada = doc.data()['musica_recomendada'];

        if (musicaRecomendada != null) {
          final musica =
              '${_capitalize(musicaRecomendada['track_name'])} - ${_capitalize(musicaRecomendada['artist_name'])}';
          if (musicasPorCidade.containsKey(cidade)) {
            musicasPorCidade[cidade]!.add(musica);
          } else {
            musicasPorCidade[cidade] = [musica];
          }
        }
      }

      // Cria marcadores para cada cidade
      for (var cidade in musicasPorCidade.keys) {
        final endereco = usersSnapshot.docs.firstWhere(
          (doc) => doc.data()['endereco']['cidade'] == cidade,
        )['endereco'];
        final estado = endereco['estado'];

        print('Buscando localização da cidade: $cidade, $estado');
        try {
          final location = await _getCoordinates(cidade, estado);
          setState(() {
            _markers.add(
              Marker(
                markerId: MarkerId(cidade),
                position: location,
                onTap: () {
                  _mostrarMusicasPopUp(
                      context, cidade, musicasPorCidade[cidade]!);
                },
              ),
            );
          });
        } catch (e) {
          print('Erro ao buscar coordenadas para $cidade, $estado: $e');
        }
      }
    } catch (e) {
      print('Erro ao buscar localizações e músicas dos usuários: $e');
    }
  }

  // Função para exibir um pop-up com as músicas recomendadas
  void _mostrarMusicasPopUp(
      BuildContext context, String cidade, List<String> musicas) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Músicas em $cidade'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: musicas.map((musica) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(musica),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  // Função para capitalizar as primeiras letras de uma string
  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  // Função para obter coordenadas usando a API de geocodificação
  Future<LatLng> _getCoordinates(String cidade, String estado) async {
    if (cidade.isEmpty || estado.isEmpty) {
      throw Exception('Cidade ou estado não podem ser vazios');
    }

    final geocoding =
        GoogleMapsGeocoding(apiKey: 'AIzaSyCJH8jQHVCjKaVmsbqzXR_Lqjn6nUna-Z4');

    try {
      print('Buscando coordenadas para: $cidade, $estado');
      final response = await geocoding.searchByComponents([
        Component('locality', cidade),
        Component('administrative_area', estado),
      ]).timeout(const Duration(seconds: 10)); // Timeout de 10 segundos

      if (response.isOkay && response.results.isNotEmpty) {
        final location = response.results.first.geometry.location;
        print('Coordenadas encontradas: ${location.lat}, ${location.lng}');
        return LatLng(location.lat, location.lng);
      } else {
        print('Nenhum resultado encontrado para $cidade, $estado');
        throw Exception('Nenhum resultado encontrado para $cidade, $estado');
      }
    } catch (e) {
      print('Erro ao buscar coordenadas: $e');
      throw Exception('Erro ao buscar coordenadas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Tendências locais'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Navegar para a tela do usuário
            },
          ),
        ],
      ),
      body: _userLocation == null
          ? const Center(child: CircularProgressIndicator())
          : _markers.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhuma localização disponível',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : GoogleMap(
                  onMapCreated: (controller) {
                    setState(() {
                      mapController = controller;
                    });
                  },
                  initialCameraPosition: CameraPosition(
                    target: _userLocation!,
                    zoom: 10,
                  ),
                  markers: _markers,
                ),
    );
  }
}
