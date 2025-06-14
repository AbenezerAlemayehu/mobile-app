import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';

class TripDetailScreen extends StatelessWidget {
  final Map<String, dynamic> trip;

  const TripDetailScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImage(),
              title: Text(
                trip['title'] ?? 'Trip Details',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTripInfo(),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implement booking functionality
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Book Now',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            trip['title'] ?? '',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                'Created by ${trip['username']}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            trip['description'] ?? '',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                trip['location'] ?? '',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                '${DateFormat('MMM d, y').format(DateTime.parse(trip['startDate']))}${trip['endDate'] != null ? ' - ${DateFormat('MMM d, y').format(DateTime.parse(trip['endDate']))}' : ''}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          if (trip['budget'] != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.attach_money_outlined, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Budget: \$${trip['budget'].toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.people_outline, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                '${trip['numberOfPeople']} ${trip['numberOfPeople'] == 1 ? 'person' : 'people'}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          if (trip['category'] != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.category_outlined, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Category: ${trip['category']}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.image, size: 50, color: Colors.grey),
      ),
    );
  }

  Widget _buildImage() {
    final imagePath = trip['imagePath'];
    if (imagePath == null || imagePath.toString().isEmpty) {
      return _buildPlaceholderImage();
    }

    // If we're on web or the path starts with http, use network image
    if (kIsWeb || imagePath.toString().startsWith('http')) {
      return Image.network(
        imagePath.toString(),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading network image: $error');
          return _buildPlaceholderImage();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    }

    // For local files on desktop/mobile
    return Image.file(
      File(imagePath.toString()),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('Error loading local image: $error');
        return _buildPlaceholderImage();
      },
    );
  }
}
