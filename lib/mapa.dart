import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_webservice/geocoding.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  _MapaScreenState createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  late GoogleMapController mapController;
  LatLng? _userLocation;
  Set<Marker> _markers = {};
  bool _showMusicBox = false;
  List<String> _musicasDaCidade = [];
  String _cidadeSelecionada = '';

  @override
  void initState() {
    super.initState();
    _fetchUserLocation();
    _fetchUsersLocationsAndMusic();
  }

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

  Future<void> _fetchUsersLocationsAndMusic() async {
    try {
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('usuarios').get();
      final Map<String, List<String>> musicasPorCidade = {};

      for (var doc in usersSnapshot.docs) {
        final endereco = doc.data()['endereco'];
        final cidade = endereco['cidade'];
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
                  setState(() {
                    _showMusicBox = true;
                    _musicasDaCidade = musicasPorCidade[cidade]!;
                    _cidadeSelecionada = cidade;
                  });
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

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

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
      ]).timeout(const Duration(seconds: 10));

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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 15,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF9E80),
                      Color(0xFFF14621),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 30),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Expanded(
                      child: Text(
                        'Tendências locais',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(Icons.person, color: Colors.white, size: 50),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFF14621),
                            width: 4,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: _userLocation == null
                            ? const Center(child: CircularProgressIndicator())
                            : _markers.isEmpty
                                ? const Center(
                                    child: Text(
                                      'Nenhuma localização disponível',
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.grey),
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
                      ),
                    ),
                  ),
                ),
                if (_showMusicBox)
                  Positioned(
                    bottom: 100,
                    left: 80,
                    right: 80,
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFF14621),
                            width: 2,
                          ),
                        ),
                        constraints: const BoxConstraints(
                          maxHeight: 150,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Músicas recomendadas em $_cidadeSelecionada',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFF14621),
                                    ),
                                    softWrap: true,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _showMusicBox = false;
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: ListView(
                                shrinkWrap: true,
                                children: _musicasDaCidade.take(3).map((musica) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Text(
                                      musica,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}