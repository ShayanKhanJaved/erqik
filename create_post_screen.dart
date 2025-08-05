import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:event_map/services/database_service.dart';
import 'package:event_map/models/post_model.dart';
import 'package:event_map/services/auth_service.dart';
import 'package:event_map/utils/constants.dart';

class CreatePostScreen extends StatefulWidget {
  final LatLng location;

  const CreatePostScreen({super.key, required this.location});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(hours: 2));
  bool _isLoading = false;

  Future<void> _selectStartTime() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_startTime),
      );
      if (time != null) {
        setState(() {
          _startTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
          if (_endTime.isBefore(_startTime)) {
            _endTime = _startTime.add(const Duration(hours: 2));
          }
        });
      }
    }
  }

  Future<void> _selectEndTime() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_endTime),
      );
      if (time != null) {
        setState(() {
          final newEnd = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
          if (newEnd.isAfter(_startTime)) {
            _endTime = newEnd;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('End time must be after start time')),
            );
          }
        });
      }
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final user = context.read<AuthService>().authStateChanges.value;
        if (user == null) throw Exception('User not authenticated');
        
        final post = Post(
          userId: user.uid,
          title: _titleController.text,
          description: _descriptionController.text,
          location: GeoPoint(widget.location.latitude, widget.location.longitude),
          startTime: Timestamp.fromDate(_startTime),
          endTime: Timestamp.fromDate(_endTime),
        );
        
        await context.read<DatabaseService>().createPost(post);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Event Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: kDefaultPadding),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: kDefaultPadding),
              ListTile(
                title: const Text('Start Time'),
                subtitle: Text(DateFormat.yMMMd().add_jm().format(_startTime)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectStartTime,
              ),
              ListTile(
                title: const Text('End Time'),
                subtitle: Text(DateFormat.yMMMd().add_jm().format(_endTime)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectEndTime,
              ),
              const SizedBox(height: kDefaultPadding),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Create Event'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}