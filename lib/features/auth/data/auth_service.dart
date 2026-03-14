import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmail(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // Record login timestamp in Firestore
    final user = userCredential.user;
    if (user != null) {
      FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)).catchError((_) {});
    }

    return userCredential;
  }

  // Register with email and password
  Future<UserCredential> registerWithEmail(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Update display name after register
  Future<void> updateDisplayName(String name) async {
    await _auth.currentUser?.updateDisplayName(name);
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // Sign out (also signs out from Google)
  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }

  // Delete account
  Future<void> deleteAccount() async {
    await _auth.currentUser?.delete();
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    // Trigger Google account picker
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null; // User cancelled

    // Get auth tokens
    final googleAuth = await googleUser.authentication;

    // Create Firebase credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign into Firebase - this is the critical step
    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;

    if (user != null) {
      // Update last login for all users
      FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)).catchError((_) {});

      // On first login — save initial user data
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        // Fire and forget - silently ignore Firestore errors
        FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': user.displayName ?? googleUser.displayName ?? '',
          'phone': '',
          'avatarIndex': 1,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)).catchError((_) {});
      }
    }

    return userCredential;
  }
}
