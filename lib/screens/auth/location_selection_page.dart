import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../constants/colors.dart';
import '../../components/custom_button.dart';
import '../../services/location_service.dart';
import '../../providers/user_provider.dart';
import '../navigations/dashboard.dart';
import '../../components/skeleton_loading.dart';

class LocationSelectionPage extends StatefulWidget {
  const LocationSelectionPage({super.key});

  @override
  State<LocationSelectionPage> createState() => _LocationSelectionPageState();
}

class _LocationSelectionPageState extends State<LocationSelectionPage> {
  final LocationService _locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  List<Place> _searchResults = [];
  Place? _selectedPlace;
  LatLng? _selectedMapLocation;
  bool _isLoading = false;
  bool _showMap = false;

  Future<void> _searchPlaces(String query) async {
    setState(() => _isLoading = true);
    try {
      final results = await _locationService.searchPlaces(query);
      setState(() => _searchResults = results);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveLocationAndContinue() async {
    if (_selectedPlace == null) return;

    try {
      await context.read<UserProvider>().updateLocation(
            _selectedPlace!.displayName,
            double.parse(_selectedPlace!.lat),
            double.parse(_selectedPlace!.lon),
          );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to save location. Please try again.')),
        );
      }
    }
  }

  void _handleContinue() {
    if (_selectedPlace != null) {
      _saveLocationAndContinue();
    }
  }

  Widget _buildLoadingSkeletons() {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: const Row(
            children: [
              SkeletonLoading(
                width: 40,
                height: 40,
                borderRadius: 20,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoading(
                      width: double.infinity,
                      height: 16,
                      borderRadius: 8,
                    ),
                    SizedBox(height: 8),
                    SkeletonLoading(
                      width: 150,
                      height: 12,
                      borderRadius: 6,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMapView() {
    // Sri Lanka's approximate bounds
    final sriLankaBounds = LatLngBounds(
      LatLng(5.916667, 79.516667), // Southwest corner
      LatLng(9.850000, 81.900000), // Northeast corner
    );

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LatLng(7.873054, 80.771797), // Center of Sri Lanka
        initialZoom: 7.5,
        minZoom: 7.0,
        maxZoom: 18.0,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
        cameraConstraint: CameraConstraint.contain(
            bounds: sriLankaBounds), // Fixed bounds parameter
        onTap: (tapPosition, point) async {
          // Only allow taps within Sri Lanka bounds
          if (sriLankaBounds.contains(point)) {
            setState(() => _selectedMapLocation = point);
            final locationName =
                await _locationService.getLocationNameFromCoords(
              point.latitude,
              point.longitude,
            );
            setState(() {
              _selectedPlace = Place(
                displayName: locationName,
                lat: point.latitude.toString(),
                lon: point.longitude.toString(),
              );
              _searchController.text = locationName;
            });
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        if (_selectedMapLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                point: _selectedMapLocation!,
                width: 40,
                height: 30,
                child: const Icon(
                  Icons.location_pin,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Your Location',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(_showMap ? Icons.search : Icons.map),
                    onPressed: () => setState(() => _showMap = !_showMap),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (!_showMap) ...[
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search location...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.length >= 3) {
                      _searchPlaces(value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _isLoading
                      ? _buildLoadingSkeletons()
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final place = _searchResults[index];
                            return ListTile(
                              title: Text(place.displayName),
                              onTap: () {
                                setState(() {
                                  _selectedPlace = place;
                                  _searchController.text = place.displayName;
                                  _searchResults = [];
                                });
                              },
                            );
                          },
                        ),
                ),
              ] else ...[
                Expanded(child: _buildMapView()),
              ],
              CustomButton(
                onPressed:
                    _selectedPlace != null ? () => _handleContinue() : null,
                text: 'Continue',
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DashboardPage(),
                      ),
                    );
                  },
                  child: const Text('Skip for now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }
}
