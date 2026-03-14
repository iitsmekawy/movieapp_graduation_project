import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:movieapp_graduation_project_amr/core/constants/app_assets.dart';

class UserService extends ChangeNotifier {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Local cache
  String _name = '';
  String _phone = '';
  String _email = '';
  int _selectedAvatarIndex = 1;

  final List<String> avatars = AppAssets.avatars;

  String get name => _name;
  String get phone => _phone;
  String get email => _email;
  int get selectedAvatarIndex => _selectedAvatarIndex;
  String get selectedAvatar => avatars[_selectedAvatarIndex];

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  /// Load user data from Firestore into local cache
  Future<void> loadFromFirestore() async {
    final uid = _uid;
    if (uid == null) return;

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _name = data['name'] ?? FirebaseAuth.instance.currentUser?.displayName ?? '';
        _phone = data['phone'] ?? '';
        _email = data['email'] ?? FirebaseAuth.instance.currentUser?.email ?? '';
        _selectedAvatarIndex = data['avatarIndex'] ?? 1;
        notifyListeners();
      } else {
        // First time — use displayName from Firebase Auth
        _name = FirebaseAuth.instance.currentUser?.displayName ?? '';
        _email = FirebaseAuth.instance.currentUser?.email ?? '';
        notifyListeners();
      }
    } catch (_) {}
  }

  /// Save new user doc to Firestore (called after registration)
  Future<void> saveToFirestore({
    required String name,
    required String phone,
    required String email,
    required int avatarIndex,
  }) async {
    final uid = _uid;
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'phone': phone,
      'email': email,
      'avatarIndex': avatarIndex,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    _name = name;
    _phone = phone;
    _email = email;
    _selectedAvatarIndex = avatarIndex;
    notifyListeners();
  }

  /// Update existing user doc in Firestore (called from Edit Profile)
  Future<void> updateInFirestore({
    String? name,
    String? phone,
    String? email,
    int? avatarIndex,
  }) async {
    final uid = _uid;
    if (uid == null) return;

    final Map<String, dynamic> updates = {
      'lastUpdated': FieldValue.serverTimestamp(),
    };
    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (email != null) updates['email'] = email;
    if (avatarIndex != null) updates['avatarIndex'] = avatarIndex;

    await _firestore.collection('users').doc(uid).update(updates);

    if (name != null) {
      _name = name;
      await FirebaseAuth.instance.currentUser?.updateDisplayName(name);
    }
    if (phone != null) _phone = phone;
    if (email != null && email != _email) {
      try {
        // Also attempt to update the actual login email in Firebase Auth
        await FirebaseAuth.instance.currentUser?.verifyBeforeUpdateEmail(email);
        _email = email;
      } catch (e) {
        // If it fails (e.g. requires-recent-login), we still updated Firestore,
        // but we should probably keep the local _email in sync with what's in Firestore
        _email = email;
        rethrow;
      }
    }
    if (avatarIndex != null) _selectedAvatarIndex = avatarIndex;
    notifyListeners();
  }

  // Local-only update (for UI state, without Firestore)
  void updateProfile({String? name, String? phone, int? avatarIndex}) {
    if (name != null) _name = name;
    if (phone != null) _phone = phone;
    if (avatarIndex != null) _selectedAvatarIndex = avatarIndex;
    notifyListeners();
  }

  /// Add a movie to history (moves to end if exists)
  Future<void> addToHistory({
    required int movieId,
    required String movieName,
    required String movieType,
  }) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      final userRef = _firestore.collection('users').doc(uid);
      
      // We store a map of movie info in the history array
      final movieData = {
        'id': movieId,
        'title': movieName,
        'type': movieType,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      // Remove any existing entry for this movie ID to avoid duplicates and update timestamp
      final doc = await userRef.get();
      final List<dynamic> history = doc.data()?['history_detailed'] ?? [];
      history.removeWhere((item) => item['id'] == movieId);
      
      // Add new entry
      history.add(movieData);

      await userRef.set({
        'history_detailed': history,
        // Keep the old simple list for backward compatibility if needed
        'history': FieldValue.arrayUnion([movieId])
      }, SetOptions(merge: true));
    } catch (e) {
      // Ignored
    }
  }

  /// Get movie history, newest first
  Future<List<int>> getHistory() async {
    final uid = _uid;
    if (uid == null) return [];
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final List<dynamic> historyDynamic = doc.data()?['history'] ?? [];
        return historyDynamic.cast<int>().reversed.toList();
      }
    } catch (e) {
      // Ignored
    }
    return [];
  }

  /// Get movie watchlist, newest first
  Future<List<int>> getWatchlist() async {
    final uid = _uid;
    if (uid == null) return [];
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final List<dynamic> watchlistDynamic = doc.data()?['watchlist'] ?? [];
        return watchlistDynamic.cast<int>().reversed.toList();
      }
    } catch (e) {
      // Ignored
    }
    return [];
  }
}
