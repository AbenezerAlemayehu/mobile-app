import 'package:frontend/models/user.dart';
import 'package:frontend/services/api_service.dart';

class Trip {
  final String id;
  final String title;
  final String description;
  final String location;
  final double? budget;
  final DateTime startDate;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? imagePath;
  final String? destination;
  final DateTime? endDate;
  final int numberOfPeople;

  Trip({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    this.budget,
    required this.startDate,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.imagePath,
    this.destination,
    this.endDate,
    this.numberOfPeople = 1,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    try {
      return Trip(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        location: json['location']?.toString() ?? '',
        budget: (json['budget'] as num?)?.toDouble(),
        startDate:
            json['startDate'] != null
                ? DateTime.parse(json['startDate'].toString())
                : DateTime.now(),
        userId: json['userId']?.toString() ?? '',
        createdAt:
            json['createdAt'] != null
                ? DateTime.parse(json['createdAt'].toString())
                : DateTime.now(),
        updatedAt:
            json['updatedAt'] != null
                ? DateTime.parse(json['updatedAt'].toString())
                : DateTime.now(),
        imagePath: json['imagePath']?.toString(),
        destination: json['destination']?.toString(),
        endDate:
            json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
        numberOfPeople: json['numberOfPeople'] as int? ?? 1,
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
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      if (budget != null) 'budget': budget,
      'startDate': startDate.toIso8601String(),
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (imagePath != null) 'imagePath': imagePath,
      if (destination != null) 'destination': destination,
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
      'numberOfPeople': numberOfPeople,
    };
  }
}
