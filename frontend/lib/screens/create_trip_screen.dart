import 'package:flutter/material.dart';
import 'package:frontend/models/trip.dart';
import 'package:frontend/services/trip_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _budgetController = TextEditingController();
  final _peopleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  DateTime? _selectedEndDate;
  String? _selectedCategory;
  String? _imagePath;
  String _uploadStatus = '';
  final _tripService = TripService();
  bool _isLoading = false;

  // Predefined categories with their images
  final Map<String, String> _categories = {
    'Adventure': 'assets/adventure.jpg',
    'Beach': 'assets/beach.jpg',
    'City': 'assets/city.jpg',
    'Mountain': 'assets/mountain.jpg',
  };

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _budgetController.dispose();
    _peopleController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      setState(() {
        _uploadStatus = 'Selecting image...';
      });

      // Use a simpler configuration that's more web-friendly
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        setState(() {
          _uploadStatus = 'No image selected';
        });
        return;
      }

      final file = result.files.first;
      print('Selected file: ${file.name}, size: ${file.size}');

      // Check file size (5MB limit)
      if (file.size > 5 * 1024 * 1024) {
        setState(() {
          _uploadStatus = 'Image size must be less than 5MB';
        });
        return;
      }

      await _uploadImage(file);
    } catch (e) {
      print('Error in _pickImage: $e');
      setState(() {
        _uploadStatus = 'Error selecting image: $e';
      });
    }
  }

  Future<void> _uploadImage(PlatformFile image) async {
    try {
      setState(() {
        _uploadStatus = 'Uploading image...';
      });

      print('Uploading image: ${image.name}');
      print('Bytes length: ${image.bytes?.length ?? 0}');

      if (image.bytes == null) {
        throw Exception('No image data available');
      }

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:5000/api/upload'),
      );

      // Add the image file to the request
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          image.bytes!,
          filename: image.name,
        ),
      );

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseBody = response.body;

      print('Response status: ${response.statusCode}');
      print('Response body: $responseBody');

      if (response.statusCode != 200) {
        throw Exception('Failed to upload image: ${response.body}');
      }

      final data = jsonDecode(responseBody);
      if (data['filePath'] == null) {
        throw Exception('Server response missing filePath');
      }

      setState(() {
        _imagePath = data['filePath'];
        _uploadStatus = 'Image uploaded successfully!';
      });

      print('Image uploaded successfully. Path: $_imagePath');
    } catch (e) {
      print('Error in _uploadImage: $e');
      setState(() {
        _uploadStatus = 'Error uploading image: $e';
      });
      rethrow;
    }
  }

  Widget _buildImagePreview() {
    if (_imagePath == null) {
      return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 50, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'No image selected',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Print the image path for debugging
    print('Building image preview with path: $_imagePath');

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage('http://localhost:5000$_imagePath'),
          fit: BoxFit.cover,
          onError: (exception, stackTrace) {
            print('Error loading image: $exception');
            print('Stack trace: $stackTrace');
            print('Attempted URL: http://localhost:5000$_imagePath');
          },
        ),
      ),
      child: _uploadStatus.isNotEmpty
          ? Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Text(
                  _uploadStatus,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Category',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories.keys.elementAt(index);
              final imagePath = _categories[category]!;
              final isSelected = _selectedCategory == category;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(10),
                        ),
                        child: Image.asset(
                          imagePath,
                          height: 80,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print('Error loading image $imagePath: $error');
                            print('Stack trace: $stackTrace');
                            return Container(
                              height: 80,
                              color: Colors.grey[300],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: Colors.red),
                                  const SizedBox(height: 4),
                                  Text(
                                    category,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.red,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        width: double.infinity,
                        color: isSelected ? Colors.blue : Colors.grey[200],
                        child: Text(
                          category,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _createTrip() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a category'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);
      try {
        // Get user info from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('userId') ?? '';
        final username = prefs.getString('username') ?? 'Unknown User';

        final tripData = {
          'title': _titleController.text,
          'description': _descriptionController.text,
          'location': _locationController.text,
          'startDate': _selectedDate.toIso8601String(),
          'endDate': _selectedEndDate?.toIso8601String(),
          'budget': _budgetController.text.isNotEmpty
              ? double.tryParse(_budgetController.text)
              : null,
          'numberOfPeople': _peopleController.text.isNotEmpty
              ? int.tryParse(_peopleController.text)
              : 1,
          'category': _selectedCategory,
          'imagePath': _categories[_selectedCategory],
          'userId': userId,
          'username': username,
        };

        final trip = Trip(
          id: '',
          userId: userId,
          username: username,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          title: tripData['title'] as String,
          description: tripData['description'] as String,
          location: tripData['location'] as String,
          startDate: DateTime.parse(tripData['startDate'] as String),
          endDate: tripData['endDate'] != null
              ? DateTime.parse(tripData['endDate'] as String)
              : null,
          budget: tripData['budget'] as double?,
          numberOfPeople: (tripData['numberOfPeople'] as int?) ?? 1,
          imagePath: tripData['imagePath'] as String?,
          category: tripData['category'] as String?,
        );

        await _tripService.createTrip(trip);

        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Trip'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategorySelector(),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a location';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _budgetController,
                            decoration: const InputDecoration(
                              labelText: 'Budget',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _peopleController,
                            decoration: const InputDecoration(
                              labelText: 'Number of People',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: const Text('Start Date'),
                            subtitle: Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            ),
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (date != null) {
                                setState(() {
                                  _selectedDate = date;
                                });
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: const Text('End Date (Optional)'),
                            subtitle: Text(
                              _selectedEndDate != null
                                  ? '${_selectedEndDate!.day}/${_selectedEndDate!.month}/${_selectedEndDate!.year}'
                                  : 'Not set',
                            ),
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _selectedEndDate ?? _selectedDate,
                                firstDate: _selectedDate,
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (date != null) {
                                setState(() {
                                  _selectedEndDate = date;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _createTrip,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Create Trip'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
