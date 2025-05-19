import 'package:frontend/models/user.dart';
import 'package:frontend/services/api_service.dart';

class Trip {
  final String id;
  final String title;
  final String description;
  final String destination;
  final double budget;
  final DateTime date;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? imagePath;
  final String? location;
  final DateTime? startDate;
  final DateTime? endDate;

  Trip({
    required this.id,
    required this.title,
    required this.description,
    required this.destination,
    required this.budget,
    required this.date,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.imagePath,
    this.location,
    this.startDate,
    this.endDate,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    try {
      return Trip(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        destination: json['destination']?.toString() ?? '',
        budget: (json['budget'] as num?)?.toDouble() ?? 0.0,
        date:
            json['date'] != null
                ? DateTime.parse(json['date'].toString())
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
        location: json['location']?.toString(),
        startDate:
            json['startDate'] != null
                ? DateTime.parse(json['startDate'].toString())
                : null,
        endDate:
            json['endDate'] != null
                ? DateTime.parse(json['endDate'].toString())
                : null,
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
      'destination': destination,
      'budget': budget,
      'date': date.toIso8601String(),
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (imagePath != null) 'imagePath': imagePath,
      if (location != null) 'location': location,
      if (startDate != null) 'startDate': startDate!.toIso8601String(),
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
    };
  }
}
