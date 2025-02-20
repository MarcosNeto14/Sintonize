import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  _MapaScreenState createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  late GoogleMapController mapController;
  LatLng? _userLocation;
  Set<Marker> _markers = {};
  String? _mostRecommendedMusic;

  @override
  void initState() {
    super.initState();
    _fetchUserLocation();
    _fetchMostRecommendedMusic();
  }

  Future<void> _fetchUserLocation() async {
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

        // Simulação de geocodificação (converter cidade/estado para coordenadas)
        // Aqui você pode usar uma API de geocodificação para obter as coordenadas reais
        final location = await _getCoordinates(cidade, estado);
        setState(() {
          _userLocation = location;
          _markers.add(
            Marker(
              markerId: MarkerId(cidade),
              position: location,
              infoWindow: InfoWindow(
                title: cidade,
                snippet: _mostRecommendedMusic != null
                    ? 'Música mais recomendada: $_mostRecommendedMusic'
                    : 'Carregando...',
              ),
            ),
          );
        });
      }
    }
  }

  Future<LatLng> _getCoordinates(String cidade, String estado) async {
    // Simulação de geocodificação
    // Substitua por uma chamada real à API de geocodificação
    return LatLng(-23.5505, -46.6333); // Exemplo: São Paulo
  }

  Future<void> _fetchMostRecommendedMusic() async {
    final usersSnapshot = await FirebaseFirestore.instance.collection('usuarios').get();
    final Map<String, int> musicCounts = {};

    for (var doc in usersSnapshot.docs) {
      final historicoMusicas = doc.data()['historico_musicas'] as Map<String, dynamic>?;
      if (historicoMusicas != null) {
        historicoMusicas.forEach((key, value) {
          final trackName = value['track_name'] as String?;
          final artistName = value['artist_name'] as String?;
          if (trackName != null && artistName != null) {
            final musicKey = '$trackName - $artistName';
            musicCounts[musicKey] = (musicCounts[musicKey] ?? 0) + 1;
          }
        });
      }
    }

    if (musicCounts.isNotEmpty) {
      final mostRecommended = musicCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      setState(() {
        _mostRecommendedMusic = mostRecommended.toUpperCase();
      });
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