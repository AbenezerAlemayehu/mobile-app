import 'package:flutter/material.dart';

class TripDetailScreen extends StatelessWidget {
  final Map<String, dynamic> trip;

  const TripDetailScreen({Key? key, required this.trip}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                trip['imageUrl'] ?? 'https://via.placeholder.com/400x300',
                fit: BoxFit.cover,
              ),
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
                  _buildInfoCard(
                    title: 'Destination',
                    content: trip['destination'] ?? 'Not specified',
                    icon: Icons.location_on,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    title: 'Dates',
                    content:
                        '${trip['startDate'] ?? 'Not set'} - ${trip['endDate'] ?? 'Not set'}',
                    icon: Icons.calendar_today,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    title: 'Description',
                    content: trip['description'] ?? 'No description available',
                    icon: Icons.description,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    title: 'Price',
                    content: '\$${trip['price']?.toString() ?? '0'}',
                    icon: Icons.attach_money,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    title: 'Number of People',
                    content:
                        '${trip['numberOfPeople']?.toString() ?? '1'} people',
                    icon: Icons.people,
                  ),
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

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
