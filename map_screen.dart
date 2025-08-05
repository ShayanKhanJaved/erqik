import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:event_map/services/location_service.dart';
import 'package:event_map/services/database_service.dart';
import 'package:event_map/models/post_model.dart';
import 'package:event_map/screens/create_post_screen.dart';
import 'package:event_map/screens/post_detail_screen.dart';
import 'package:event_map/widgets/post_pin.dart';
import 'package:event_map/utils/constants.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  bool _isLoading = true;
  bool _showCreateButton = true;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      final position = await context.read<LocationService>().getCurrentLocation();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
      _mapController.move(_currentPosition!, 15.0);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location error: $e')),
      );
    }
  }

  void _onMapCreated() {
    if (_currentPosition != null) {
      _mapController.move(_currentPosition!, 15.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthService>().signOut(),
          ),
        ],
      ),
      floatingActionButton: _showCreateButton
          ? FloatingActionButton(
              backgroundColor: kPrimaryColor,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreatePostScreen(
                      location: _currentPosition!,
                    ),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<Post>>(
              stream: context.read<DatabaseService>().activePosts,
              builder: (context, snapshot) {
                final posts = snapshot.data ?? [];
                
                return FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: _currentPosition,
                    zoom: 15.0,
                    onMapReady: _onMapCreated,
                    onPositionChanged: (_, __) {
                      setState(() => _showCreateButton = false);
                    },
                    onPointerDown: (_, __) {
                      setState(() => _showCreateButton = true);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.event_map',
                      tileBuilder: (context, tileWidget, tile) {
                        return ColorFiltered(
                          colorFilter: const ColorFilter.matrix([
                            0.5, 0.0, 0.0, 0, 0,  // Red scale
                            0.5, 0.3, 0.0, 0, 0,  // Green scale
                            0.0, 0.0, 0.1, 0, 0,  // Blue scale
                            0,    0,    0,  1, 0,
                          ]),
                          child: tileWidget,
                        );
                      },
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentPosition!,
                          width: 40,
                          height: 40,
                          builder: (ctx) => const Icon(
                            Icons.location_pin,
                            color: Colors.blue,
                            size: 40,
                          ),
                        ),
                        ...posts.map((post) => Marker(
                              point: LatLng(
                                post.location.latitude,
                                post.location.longitude,
                              ),
                              width: 40,
                              height: 40,
                              builder: (ctx) => GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PostDetailScreen(post: post),
                                    ),
                                  );
                                },
                                child: PostPin(isActive: post.isActive),
                              ),
                            )),
                      ],
                    ),
                  ],
                );
              },
            ),
    );
  }
}