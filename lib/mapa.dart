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
      for (var doc in usersSnapshot.docs) {
        final endereco = doc.data()['endereco'];
        final cidade = endereco['cidade'];
        final estado = endereco['estado'];
        final musicaRecomendada = doc.data()['musica_recomendada'];

        print('Buscando localização do usuário: $cidade, $estado');
        try {
          final location = await _getCoordinates(cidade, estado);
          setState(() {
            _markers.add(
              Marker(
                markerId: MarkerId(doc.id),
                position: location,
                infoWindow: InfoWindow(
                  title: cidade,
                  snippet: musicaRecomendada != null
                      ? 'Música recomendada: ${musicaRecomendada['track_name']} - ${musicaRecomendada['artist_name']}'
                      : 'Nenhuma música recomendada',
                ),
              ),
            );
          });
        } catch (e) {
          print('Erro ao buscar coordenadas para $cidade, $estado: $e');
          // Ignora o erro e continua com os próximos usuários
        }
      }
    } catch (e) {
      print('Erro ao buscar localizações e músicas dos usuários: $e');
    }
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
              ? const Center(child: Text('Nenhuma localização disponível'))
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
