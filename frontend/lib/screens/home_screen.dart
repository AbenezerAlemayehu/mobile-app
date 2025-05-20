import 'package:flutter/material.dart';
import 'package:frontend/models/trip.dart';
import 'package:frontend/screens/create_trip_screen.dart';
import 'package:frontend/screens/trip_detail_screen.dart';
import 'package:frontend/services/trip_service.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

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
  int _currentImageIndex = 0;

  final List<String> _featuredImages = [
    'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800',
    'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1',
    'https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
    'https://images.unsplash.com/photo-1516483638261-f4dbaf036963',
  ];

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
      final trips = await _tripService.getTrips();
      setState(() {
        _trips = trips;
        _isLoading = false;
      });
    } catch (e) {
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
        elevation: 0,
        backgroundColor: const Color(0xFF1E8449), // Dark green
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTrips,
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text('John Doe'),
              accountEmail: const Text('john.doe@example.com'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: Image.network(
                    'https://via.placeholder.com/150',
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF1E8449), // Dark green
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Color(0xFF1E8449)),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF1E8449)),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFF1E8449)),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFF1E8449)),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E8449),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  FlutterCarousel(
                    items:
                        _featuredImages.map((imageUrl) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        }).toList(),
                    options: CarouselOptions(
                      height: 200.0,
                      showIndicator: true,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 3),
                      viewportFraction: 0.9,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child:
                        _trips.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.card_travel,
                                    size: 64,
                                    color: Color(0xFF1E8449),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No trips yet',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Create your first trip!',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    onPressed: _navigateToCreateTrip,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Create Trip'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1E8449),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => TripDetailScreen(
                                                trip: {
                                                  'title': trip.title,
                                                  'destination': trip.location,
                                                  'startDate':
                                                      trip.startDate
                                                          ?.toString()
                                                          .split(' ')[0],
                                                  'endDate':
                                                      trip.endDate
                                                          ?.toString()
                                                          .split(' ')[0],
                                                  'description':
                                                      trip.description,
                                                  'imageUrl': trip.imagePath,
                                                  'price': trip.budget,
                                                  'numberOfPeople':
                                                      trip.numberOfPeople,
                                                },
                                              ),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: _buildTripImage(trip),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  trip.title,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                if (trip.location != null &&
                                                    trip.location!.isNotEmpty)
                                                  Text(
                                                    trip.location!,
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                if (trip.startDate != null)
                                                  Text(
                                                    'Start: ${trip.startDate!.toString().split(' ')[0]}',
                                                    style: const TextStyle(
                                                      color: Color(0xFF1E8449),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          const Icon(Icons.chevron_right),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateTrip,
        icon: const Icon(Icons.add),
        label: const Text('New Trip'),
        backgroundColor: const Color(0xFF1E8449),
        foregroundColor: Colors.white,
      ),
    );
  }
}
