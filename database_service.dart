import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_map/models/post_model.dart';
import 'package:uuid/uuid.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createPost(Post post) async {
    try {
      await _firestore.collection('posts').doc(post.id).set(post.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<Post>> get activePosts {
    return _firestore
        .collection('posts')
        .where('endTime', isGreaterThan: Timestamp.now())
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Post.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addAttendee(String postId, String userId) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'attendees': FieldValue.arrayUnion([userId])
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addComment(String postId, String userId, String text) async {
    try {
      final commentId = const Uuid().v4();
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .set({
        'userId': userId,
        'text': text,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      rethrow;
    }
  }
}