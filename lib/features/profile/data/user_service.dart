import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:movieapp_graduation_project_amr/core/constants/app_assets.dart';

class UserService extends ChangeNotifier {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Future<void> loadFromFirestore() async {
    final uid = _uid;
    if (uid == null) return;

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _name = data['name'] ??
            FirebaseAuth.instance.currentUser?.displayName ??
            '';
        _phone = data['phone'] ?? '';
        _email =
            data['email'] ?? FirebaseAuth.instance.currentUser?.email ?? '';
        _selectedAvatarIndex = data['avatarIndex'] ?? 1;
        notifyListeners();
      } else {
        _name = FirebaseAuth.instance.currentUser?.displayName ?? '';
        _email = FirebaseAuth.instance.currentUser?.email ?? '';
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading from Firestore: $e');
    }
  }

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
        await FirebaseAuth.instance.currentUser?.verifyBeforeUpdateEmail(email);
        _email = email;
      } catch (e) {
        _email = email;
        rethrow;
      }
    }
    if (avatarIndex != null) _selectedAvatarIndex = avatarIndex;
    notifyListeners();
  }

  void updateProfile({String? name, String? phone, int? avatarIndex}) {
    if (name != null) _name = name;
    if (phone != null) _phone = phone;
    if (avatarIndex != null) _selectedAvatarIndex = avatarIndex;
    notifyListeners();
  }

  Future<void> addToHistory({
    required int movieId,
    required String movieName,
    required String movieType,
  }) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      final userRef = _firestore.collection('users').doc(uid);

      final movieData = {
        'id': movieId,
        'title': movieName,
        'type': movieType,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      final doc = await userRef.get();
      final List<dynamic> history = doc.data()?['history_detailed'] ?? [];
      history.removeWhere((item) => item['id'] == movieId);

      history.add(movieData);

      await userRef.set({
        'history_detailed': history,
        'history': FieldValue.arrayUnion([movieId])
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error adding to history: $e');
    }
  }

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
      debugPrint('Error getting history: $e');
    }
    return [];
  }

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
      debugPrint('Error getting watchlist: $e');
    }
    return [];
  }
}
