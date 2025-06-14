class Trip {
  final String id;
  final String userId;
  final String username;
  final String title;
  final String description;
  final String location;
  final double? budget;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? imagePath;
  final int numberOfPeople;
  final String? category;

  Trip({
    required this.id,
    required this.userId,
    required this.username,
    required this.title,
    required this.description,
    required this.location,
    this.budget,
    required this.startDate,
    this.endDate,
    required this.createdAt,
    required this.updatedAt,
    this.imagePath,
    this.numberOfPeople = 1,
    this.category,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    try {
      String extractedUserId = '';
      String extractedUsername = 'Unknown User';

      // Handle the 'user' field, which can be null, a String (user ID), or a Map (user object)
      if (json.containsKey('user') && json['user'] != null) {
        if (json['user'] is String) {
          extractedUserId = json['user'] as String;
        } else if (json['user'] is Map) {
          final userMap = json['user'] as Map<String, dynamic>;
          extractedUserId = userMap['_id'] ?? '';
          extractedUsername = userMap['username'] ?? 'Unknown User';
        }
      }

      return Trip(
        id: json['_id'] ?? '',
        userId: extractedUserId,
        username: extractedUsername,
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        location: json['location'] ?? '',
        budget: json['budget']?.toDouble(),
        startDate: DateTime.parse(json['startDate']),
        endDate:
            json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        imagePath: json['imagePath'] is String ? json['imagePath'] : null,
        numberOfPeople: json['numberOfPeople'] ?? 1,
        category: json['category'] is String ? json['category'] : null,
      );
    } catch (e, stackTrace) {
      print('Error parsing trip JSON: $e');
      print('Stack trace: $stackTrace');
      print('Problematic JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'username': username,
      'title': title,
      'description': description,
      'location': location,
      if (budget != null) 'budget': budget,
      'startDate': startDate.toIso8601String(),
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (imagePath != null) 'imagePath': imagePath,
      'numberOfPeople': numberOfPeople,
      if (category != null) 'category': category,
    };
  }
}
