import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/trip.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

class TripService {
  static const String baseUrl = 'http://localhost:5000/api';

  Future<Map<String, String>> _getHeaders() async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    // Get the authentication token
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<Trip> createTrip(Trip trip) async {
    try {
      // Validate required fields
      if (trip.title == null ||
          trip.title!.isEmpty ||
          trip.description == null ||
          trip.description!.isEmpty ||
          trip.location == null ||
          trip.location!.isEmpty ||
          trip.startDate == null) {
        throw Exception(
          'Title, description, location, and startDate are required.',
        );
      }

      final tripData = {
        'title': trip.title!,
        'description': trip.description!,
        'location': trip.location!,
        'startDate': trip.startDate!.toIso8601String(),
        'numberOfPeople': trip.numberOfPeople.toString(),
        if (trip.endDate != null) 'endDate': trip.endDate!.toIso8601String(),
        if (trip.destination != null) 'destination': trip.destination!,
        if (trip.budget != null) 'budget': trip.budget.toString(),
        if (trip.userId.isNotEmpty) 'userId': trip.userId,
        'createdAt': trip.createdAt.toIso8601String(),
        'updatedAt': trip.updatedAt.toIso8601String(),
      };

      print('Sending trip data: $tripData'); // Debug log

      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/trips'),
        headers: headers,
        body: jsonEncode(tripData),
      );

      print('Server response status: ${response.statusCode}');
      print('Server response body: ${response.body}');

      if (response.statusCode == 201) {
        return Trip.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Authentication required. Please login again.');
      } else {
        throw Exception('Failed to create trip: ${response.body}');
      }
    } catch (e) {
      print('Error creating trip: $e');
      throw Exception('Error creating trip: $e');
    }
  }

  Future<List<Trip>> getTrips() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/trips'),
        headers: headers,
      );

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
      } else if (response.statusCode == 401) {
        throw Exception('Authentication required. Please login again.');
      } else {
        throw Exception('Failed to load trips: ${response.body}');
      }
    } catch (e) {
      print('Error parsing trips: $e'); // Debug log
      throw Exception('Error loading trips: $e');
    }
  }
}
