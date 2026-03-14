import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MovieInteractionService {
  static final MovieInteractionService _instance = MovieInteractionService._internal();
  factory MovieInteractionService() => _instance;
  MovieInteractionService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // ─── Likes ────────────────────────────────────────────────

  /// Toggle like for a movie — returns the new liked state
  Future<bool> toggleLike({
    required int movieId,
    required String movieName,
    required String movieType,
  }) async {
    final uid = _uid;
    if (uid == null) return false;

    final movieRef = _firestore.collection('movies').doc(movieId.toString());
    final userRef = _firestore.collection('users').doc(uid);

    try {
      return await _firestore.runTransaction<bool>((transaction) async {
        final movieSnap = await transaction.get(movieRef);
        final movieData = movieSnap.data() ?? {};
        final likes = Map<String, dynamic>.from(movieData['likes'] ?? {});

        final userSnap = await transaction.get(userRef);
        final userData = userSnap.data() ?? {};
        final List<dynamic> likedDetailed = List.from(userData['liked_movies_detailed'] ?? []);

        if (likes.containsKey(uid)) {
          // Unlike
          likes.remove(uid);
          likedDetailed.removeWhere((item) => item['id'] == movieId);
          
          transaction.set(movieRef, {
            'likes': likes,
            'title': movieName,
            'type': movieType,
          }, SetOptions(merge: true));

          transaction.set(userRef, {
            'liked_movies': FieldValue.arrayRemove([movieId]),
            'liked_movies_detailed': likedDetailed,
          }, SetOptions(merge: true));

          return false;
        } else {
          // Like
          likes[uid] = true;
          
          final movieEntry = {
            'id': movieId,
            'title': movieName,
            'type': movieType,
            'likedAt': DateTime.now().millisecondsSinceEpoch,
          };

          // Add to detailed list
          likedDetailed.add(movieEntry);

          transaction.set(movieRef, {
            'likes': likes,
            'title': movieName,
            'type': movieType,
          }, SetOptions(merge: true));

          // Also add to watchlist since user wants loved movies in wishlist
          final List<dynamic> watchlistDetailed = List.from(userData['watchlist_detailed'] ?? []);
          if (!watchlistDetailed.any((item) => item['id'] == movieId)) {
            watchlistDetailed.add({
              'id': movieId,
              'title': movieName,
              'type': movieType,
              'savedAt': DateTime.now().millisecondsSinceEpoch,
            });
          }

          transaction.set(userRef, {
            'liked_movies': FieldValue.arrayUnion([movieId]),
            'liked_movies_detailed': likedDetailed,
            'watchlist': FieldValue.arrayUnion([movieId]),
            'watchlist_detailed': watchlistDetailed,
          }, SetOptions(merge: true));

          return true;
        }
      });
    } catch (e) {
      return false;
    }
  }

  /// Stream of like count + whether current user liked
  Stream<({int count, bool isLiked})> likesStream(int movieId) {
    final uid = _uid;
    return _firestore
        .collection('movies')
        .doc(movieId.toString())
        .snapshots()
        .map((snap) {
      final data = snap.data() ?? {};
      final likes = Map<String, dynamic>.from(data['likes'] ?? {});
      return (count: likes.length, isLiked: uid != null && likes.containsKey(uid));
    });
  }

  // ─── Saves (Bookmark) ─────────────────────────────────────

  /// Toggle save for a movie — returns the new saved state
  Future<bool> toggleSave({
    required int movieId,
    required String movieName,
    required String movieType,
  }) async {
    final uid = _uid;
    if (uid == null) return false;

    final movieRef = _firestore.collection('movies').doc(movieId.toString());
    final userRef = _firestore.collection('users').doc(uid);

    try {
      return await _firestore.runTransaction<bool>((transaction) async {
        final movieSnap = await transaction.get(movieRef);
        final movieData = movieSnap.data() ?? {};
        final saves = Map<String, dynamic>.from(movieData['saves'] ?? {});

        final userSnap = await transaction.get(userRef);
        final userData = userSnap.data() ?? {};
        final List<dynamic> watchlistDetailed = List.from(userData['watchlist_detailed'] ?? []);

        if (saves.containsKey(uid)) {
          // Unsave
          saves.remove(uid);
          watchlistDetailed.removeWhere((item) => item['id'] == movieId);

          transaction.set(movieRef, {
            'saves': saves,
            'title': movieName,
            'type': movieType,
          }, SetOptions(merge: true));
          
          transaction.set(userRef, {
            'watchlist': FieldValue.arrayRemove([movieId]),
            'watchlist_detailed': watchlistDetailed,
          }, SetOptions(merge: true));
          
          return false;
        } else {
          // Save
          saves[uid] = true;
          watchlistDetailed.add({
            'id': movieId,
            'title': movieName,
            'type': movieType,
            'savedAt': DateTime.now().millisecondsSinceEpoch,
          });

          transaction.set(movieRef, {
            'saves': saves,
            'title': movieName,
            'type': movieType,
          }, SetOptions(merge: true));

          transaction.set(userRef, {
            'watchlist': FieldValue.arrayUnion([movieId]),
            'watchlist_detailed': watchlistDetailed,
          }, SetOptions(merge: true));
          
          return true;
        }
      });
    } catch (e) {
      return false;
    }
  }

  /// Stream of whether current user saved this movie
  Stream<bool> saveStream(int movieId) {
    final uid = _uid;
    return _firestore
        .collection('movies')
        .doc(movieId.toString())
        .snapshots()
        .map((snap) {
      final data = snap.data() ?? {};
      final saves = Map<String, dynamic>.from(data['saves'] ?? {});
      return uid != null && saves.containsKey(uid);
    });
  }
}
