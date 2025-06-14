import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/trip.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart' show kIsWeb;

class TripService {
  static const String baseUrl = 'http://localhost:5000/api';

  Future<Map<String, String>> _getHeaders() async {
    final headers = <String, String>{'Accept': 'application/json'};

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
      print('Creating trip with data: ${trip.toJson()}');

      // Create a multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/trips'),
      );

      // Add headers
      final headers = await _getHeaders();
      request.headers.addAll(headers);

      // Add text fields
      request.fields.addAll({
        'title': trip.title,
        'description': trip.description,
        'location': trip.location,
        'startDate': trip.startDate.toIso8601String(),
        if (trip.endDate != null) 'endDate': trip.endDate!.toIso8601String(),
        if (trip.budget != null) 'budget': trip.budget.toString(),
        'numberOfPeople': trip.numberOfPeople.toString(),
      });

      // Add image file if present
      if (trip.imagePath != null && trip.imagePath!.isNotEmpty) {
        print('Adding image file to request: ${trip.imagePath}');

        if (kIsWeb) {
          // For web platform, we need to get the image bytes from the server
          final imageResponse = await http.get(
            Uri.parse('$baseUrl${trip.imagePath}'),
          );
          if (imageResponse.statusCode == 200) {
            request.files.add(
              http.MultipartFile.fromBytes(
                'image',
                imageResponse.bodyBytes,
                filename: path.basename(trip.imagePath!),
              ),
            );
            print('Image file added to request successfully for web platform');
          } else {
            print(
              'Failed to get image from server: ${imageResponse.statusCode}',
            );
          }
        } else {
          // For mobile platform, use the local file
          final imageFile = File(trip.imagePath!);
          if (await imageFile.exists()) {
            request.files.add(
              await http.MultipartFile.fromPath('image', imageFile.path),
            );
            print(
              'Image file added to request successfully for mobile platform',
            );
          } else {
            print('Image file does not exist at path: ${trip.imagePath}');
          }
        }
      }

      print('Sending multipart request with fields: ${request.fields}');
      print('Number of files in request: ${request.files.length}');

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Server response status: ${response.statusCode}');
      print('Server response body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print('Server response data: $responseData');
        if (responseData['trip'] != null) {
          final trip = Trip.fromJson(responseData['trip']);
          print('Created trip with image path: ${trip.imagePath}');
          return trip;
        } else {
          throw Exception('Invalid response format: trip data is missing');
        }
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
        print('API Response: $responseData');

        if (responseData.containsKey('trips')) {
          final List<dynamic> tripsJson = responseData['trips'];
          return tripsJson.map((json) => Trip.fromJson(json)).toList();
        } else {
          return [Trip.fromJson(responseData)];
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication required. Please login again.');
      } else {
        throw Exception('Failed to load trips: ${response.body}');
      }
    } catch (e) {
      print('Error loading trips: $e');
      throw Exception('Error loading trips: $e');
    }
  }
}
