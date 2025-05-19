import 'package:flutter/material.dart';
import 'package:frontend/models/trip.dart';
import 'package:frontend/screens/create_trip_screen.dart';
import 'package:frontend/services/trip_service.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Trip> _trips = [];
  bool _isLoading = true;
  String? _error;
  final _tripService = TripService();

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      print('Loading trips...'); // Debug log
      final trips = await _tripService.getTrips();
      print('Trips loaded successfully: ${trips.length}'); // Debug log
      setState(() {
        _trips = trips;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading trips: $e'); // Debug log
      setState(() {
        _error = 'Failed to load trips: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToCreateTrip() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateTripScreen()),
    );
    if (result == true) {
      _loadTrips();
    }
  }

  Widget _buildTripImage(Trip trip) {
    if (trip.imagePath == null) {
      return const Icon(Icons.image, size: 56);
    }

    if (kIsWeb) {
      return Image.network(
        trip.imagePath!,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading web image: $error');
          return const Icon(Icons.image_not_supported, size: 56);
        },
      );
    } else {
      return Image.file(
        File(trip.imagePath!),
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading file image: $error');
          return const Icon(Icons.image_not_supported, size: 56);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadTrips),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadTrips,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : _trips.isEmpty
              ? const Center(
                child: Text('No trips yet. Create your first trip!'),
              )
              : ListView.builder(
                itemCount: _trips.length,
                itemBuilder: (context, index) {
                  final trip = _trips[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildTripImage(trip),
                      ),
                      title: Text(trip.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (trip.location != null &&
                              trip.location!.isNotEmpty)
                            Text(trip.location!),
                          if (trip.startDate != null)
                            Text(
                              'Start: ${trip.startDate!.toString().split(' ')[0]}',
                            ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO: Navigate to trip details
                      },
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateTrip,
        child: const Icon(Icons.add),
      ),
    );
  }
}
