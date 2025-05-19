import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/trip.dart';

class TripService {
  static const String baseUrl =
      'http://localhost:5000/api'; // Updated to match ApiService

  Future<Trip> createTrip(Trip trip) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/trips'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(trip.toJson()),
      );

      if (response.statusCode == 201) {
        return Trip.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create trip: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating trip: $e');
    }
  }

  Future<List<Trip>> getTrips() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/trips'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print('API Response: $responseData'); // Debug log

        // Check if the response has a 'trips' field
        if (responseData.containsKey('trips')) {
          final List<dynamic> tripsJson = responseData['trips'];
          return tripsJson.map((json) => Trip.fromJson(json)).toList();
        } else {
          // If the response is a single trip object
          return [Trip.fromJson(responseData)];
        }
      } else {
        throw Exception('Failed to load trips: ${response.body}');
      }
    } catch (e) {
      print('Error parsing trips: $e'); // Debug log
      throw Exception('Error loading trips: $e');
    }
  }

  Future<Trip> getTrip(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/trips/$id'));

      if (response.statusCode == 200) {
        return Trip.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load trip: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading trip: $e');
    }
  }

  Future<Trip> updateTrip(Trip trip) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/trips/${trip.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(trip.toJson()),
      );

      if (response.statusCode == 200) {
        return Trip.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update trip: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating trip: $e');
    }
  }

  Future<void> deleteTrip(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/trips/$id'));

      if (response.statusCode != 200) {
        throw Exception('Failed to delete trip: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting trip: $e');
    }
  }
}
