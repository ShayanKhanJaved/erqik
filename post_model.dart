import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class Post {
  final String id;
  final String userId;
  final String title;
  final String description;
  final GeoPoint location;
  final Timestamp startTime;
  final Timestamp endTime;
  final Timestamp createdAt;
  final List<String> attendees;

  Post({
    String? id,
    required this.userId,
    required this.title,
    required this.description,
    required this.location,
    required this.startTime,
    required this.endTime,
    List<String>? attendees,
  })  : id = id ?? const Uuid().v4(),
        createdAt = Timestamp.now(),
        attendees = attendees ?? [];

  factory Post.fromMap(Map<String, dynamic> map, String id) {
    return Post(
      id: id,
      userId: map['userId'],
      title: map['title'],
      description: map['description'],
      location: map['location'],
      startTime: map['startTime'],
      endTime: map['endTime'],
      attendees: List<String>.from(map['attendees'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'location': location,
      'startTime': startTime,
      'endTime': endTime,
      'createdAt': createdAt,
      'attendees': attendees,
    };
  }

  bool get isActive => endTime.toDate().isAfter(DateTime.now());
}