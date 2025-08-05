import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:event_map/models/post_model.dart';
import 'package:event_map/services/database_service.dart';
import 'package:event_map/services/auth_service.dart';
import 'package:event_map/utils/constants.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentController = TextEditingController();
  bool _isAttending = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAttendance();
  }

  void _checkAttendance() {
    final userId = context.read<AuthService>().authStateChanges.value?.uid;
    if (userId != null) {
      setState(() {
        _isAttending = widget.post.attendees.contains(userId);
      });
    }
  }

  Future<void> _toggleAttendance() async {
    final userId = context.read<AuthService>().authStateChanges.value?.uid;
    if (userId == null) return;

    setState(() => _isLoading = true);
    
    try {
      if (_isAttending) {
        // TODO: Implement remove attendance
      } else {
        await context
            .read<DatabaseService>()
            .addAttendee(widget.post.id, userId);
        setState(() => _isAttending = true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.isEmpty) return;

    final userId = context.read<AuthService>().authStateChanges.value?.uid;
    if (userId == null) return;

    setState(() => _isLoading = true);
    
    try {
      await context.read<DatabaseService>().addComment(
            widget.post.id,
            userId,
            _commentController.text,
          );
      _commentController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.post.title)),
      body: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.post.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              'Location: ${widget.post.location.latitude.toStringAsFixed(4)}, '
              '${widget.post.location.longitude.toStringAsFixed(4)}',
            ),
            Text(
              'Starts: ${DateFormat.yMMMd().add_jm().format(widget.post.startTime.toDate())}',
            ),
            Text(
              'Ends: ${DateFormat.yMMMd().add_jm().format(widget.post.endTime.toDate())}',
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _toggleAttendance,
                    child: Text(_isAttending ? 'Cancel Attendance' : 'I\'m Attending'),
                  ),
            const SizedBox(height: 20),
            const Text('Comments', style: TextStyle(fontSize: 18)),
            // TODO: Implement comments list
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _addComment,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}