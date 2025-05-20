import 'package:flutter/material.dart';
import 'package:frontend/models/trip.dart';
import 'package:frontend/services/trip_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

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
  DateTime _selectedEndDate = DateTime.now();
  String? _imagePath;
  final _tripService = TripService();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _budgetController.dispose();
    _peopleController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null && picked != _selectedEndDate) {
      setState(() {
        _selectedEndDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pick from gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1800,
                    maxHeight: 1800,
                  );
                  if (image != null) {
                    setState(() {
                      _imagePath = image.path;
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 1800,
                    maxHeight: 1800,
                  );
                  if (image != null) {
                    setState(() {
                      _imagePath = image.path;
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _createTrip() async {
    if (_formKey.currentState!.validate()) {
      try {
        final trip = Trip(
          id: '', // Will be set by the server
          title: _titleController.text,
          description: _descriptionController.text,
          location: _locationController.text,
          budget: double.tryParse(_budgetController.text),
          startDate: _selectedDate,
          endDate: _selectedEndDate,
          userId: '', // Will be set by the server
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          imagePath: _imagePath,
          numberOfPeople: int.tryParse(_peopleController.text) ?? 1,
        );

        await _tripService.createTrip(trip);
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating trip: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildImagePreview() {
    if (_imagePath == null) {
      return Container(
        width: double.infinity,
        height: 200,
        color: Colors.grey[200],
        child: const Icon(Icons.add_a_photo, size: 50),
      );
    }

    if (kIsWeb) {
      return Image.network(
        _imagePath!,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 200,
            color: Colors.grey[200],
            child: const Icon(Icons.error, size: 50),
          );
        },
      );
    } else {
      return Image.file(
        File(_imagePath!),
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 200,
            color: Colors.grey[200],
            child: const Icon(Icons.error, size: 50),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Trip'),
        backgroundColor: const Color(0xFF1E8449),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildImagePreview(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
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
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
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
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
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
                      decoration: InputDecoration(
                        labelText: 'Budget',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        prefixText: '\$ ',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _peopleController,
                      decoration: InputDecoration(
                        labelText: 'Number of People',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final number = int.tryParse(value);
                        if (number == null || number < 1) {
                          return 'Min: 1';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: const Text('Start Date'),
                  subtitle: Text(
                    _selectedDate.toString().split(' ')[0],
                    style: const TextStyle(
                      color: Color(0xFF1E8449),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _selectDate,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: const Text('End Date'),
                  subtitle: Text(
                    _selectedEndDate.toString().split(' ')[0],
                    style: const TextStyle(
                      color: Color(0xFF1E8449),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _selectEndDate,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _createTrip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E8449),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Create Trip',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
