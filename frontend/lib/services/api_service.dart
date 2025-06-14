import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/models/trip.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiService {
  static String get baseUrl {
    // For web, use the full URL to the backend server
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }

    // For mobile, use the local development server
    // You can change this to your actual server IP if needed
    return 'http://localhost:5000/api';
  }

  static Future<Map<String, String>> getHeaders(bool authenticated) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json', // Add this to ensure we get JSON responses
    };
    if (authenticated) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Future<Map<String, dynamic>> signup(
    String username,
    String email,
    String password,
  ) async {
    try {
      print('Attempting signup with: $email'); // Debug log
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: await getHeaders(false),
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      print('Signup response status: ${response.statusCode}'); // Debug log
      print('Signup response body: ${response.body}'); // Debug log

      if (response.statusCode != 201) {
        throw Exception('Signup failed: ${response.body}');
      }

      return jsonDecode(response.body);
    } catch (e) {
      print('Signup error: $e'); // Debug log
      throw Exception('Failed to sign up: $e');
    }
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      print('Attempting login with: $email'); // Debug log
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: await getHeaders(false),
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Login response status: ${response.statusCode}'); // Debug log
      print('Login response body: ${response.body}'); // Debug log

      if (response.statusCode != 200) {
        throw Exception('Login failed: ${response.body}');
      }

      final data = jsonDecode(response.body);
      if (data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
      }
      return data;
    } catch (e) {
      print('Login error: $e'); // Debug log
      throw Exception('Failed to login: $e');
    }
  }

  static Future<List<Trip>> getAllTrips() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/trips'),
        headers: await getHeaders(true),
      );

      print('Get trips response status: ${response.statusCode}');
      print('Get trips response body: ${response.body}');

      if (response.statusCode == 401) {
        throw Exception('Authentication required. Please login again.');
      } else if (response.statusCode != 200) {
        throw Exception('Failed to fetch trips: ${response.body}');
      }

      final responseData = jsonDecode(response.body);
      if (responseData['trips'] == null) {
        throw Exception('Invalid response format: trips field is missing');
      }

      final List<dynamic> tripList = responseData['trips'];
      print('Parsing ${tripList.length} trips...');

      return tripList.map((json) {
        try {
          print('Parsing trip: ${json.toString()}');
          return Trip.fromJson(json);
        } catch (e, stackTrace) {
          print('Error parsing trip: $e');
          print('Stack trace: $stackTrace');
          print('Problematic JSON: $json');
          rethrow;
        }
      }).toList();
    } catch (e) {
      print('Error fetching trips: $e');
      throw Exception('Failed to fetch trips: $e');
    }
  }

  static Future<Map<String, dynamic>> createTrip(
    Map<String, dynamic> tripData,
  ) async {
    try {
      print('Creating trip with data: $tripData'); // Debug log

      // Validate required fields
      if (tripData['title'] == null || tripData['title'].toString().isEmpty) {
        throw Exception('Title is required');
      }
      if (tripData['description'] == null ||
          tripData['description'].toString().isEmpty) {
        throw Exception('Description is required');
      }
      if (tripData['location'] == null ||
          tripData['location'].toString().isEmpty) {
        throw Exception('Location is required');
      }
      if (tripData['startDate'] == null) {
        throw Exception('Start date is required');
      }

      // Create a multipart request for file upload
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/trips'),
      );

      // Add headers
      final headers = await getHeaders(true);
      // Remove Content-Type header as it will be set automatically for multipart
      headers.remove('Content-Type');
      request.headers.addAll(headers);

      // Add required text fields
      request.fields.addAll({
        'title': tripData['title'].toString(),
        'description': tripData['description'].toString(),
        'location': tripData['location'].toString(),
        'startDate': tripData['startDate'].toString(),
      });

      // Add optional fields if present
      if (tripData['endDate'] != null) {
        request.fields['endDate'] = tripData['endDate'].toString();
      }
      if (tripData['budget'] != null) {
        request.fields['budget'] = tripData['budget'].toString();
      }
      if (tripData['numberOfPeople'] != null) {
        request.fields['numberOfPeople'] =
            tripData['numberOfPeople'].toString();
      }

      // Add image file if present
      if (tripData['imagePath'] != null) {
        print('Processing image at path: ${tripData['imagePath']}');
        final imageFile = File(tripData['imagePath']);
        if (await imageFile.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath('image', imageFile.path),
          );
          print('Image file added to request successfully');
        } else {
          print('Image file does not exist at path: ${tripData['imagePath']}');
        }
      }

      print('Sending request with fields: ${request.fields}');
      print('Sending request with files: ${request.files.length}');

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Create trip response status: ${response.statusCode}');
      print('Create trip response body: ${response.body}');

      if (response.statusCode != 201) {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          'Failed to create trip: ${errorBody['message'] ?? response.body}',
        );
      }

      final result = jsonDecode(response.body);
      print('Trip creation result: $result');
      return result;
    } catch (e) {
      print('Create trip error: $e');
      throw Exception('Failed to create trip: $e');
    }
  }

  // Implement more API service methods for other features (e.g., fetching single trip)
}
