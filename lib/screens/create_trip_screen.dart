import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../services/trip_service.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _destinationController = TextEditingController();
  final _budgetController = TextEditingController();
  DateTime _selectedDate = DateTime.now(); // Initialize with current date
  final _tripService = TripService();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now(); // Ensure date is set in initState
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _destinationController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _createTrip() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final trip = Trip(
        id: '', // This will be set by the backend
        title: _titleController.text,
        description: _descriptionController.text,
        destination: _destinationController.text,
        budget: double.parse(_budgetController.text),
        date: _selectedDate, // Now we know this is not null
        userId: '', // This will be set by the backend
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final createdTrip = await _tripService.createTrip(trip);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trip created successfully!')),
        );
        Navigator.pop(context, createdTrip);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating trip: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Trip')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _destinationController,
                decoration: const InputDecoration(labelText: 'Destination'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a destination';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _budgetController,
                decoration: const InputDecoration(labelText: 'Budget'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a budget';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date'),
                subtitle: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _createTrip,
                child: const Text('Create Trip'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
