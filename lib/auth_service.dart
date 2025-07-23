// lib/services/auth_service.dart
// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


class AuthService {
  static Future<UserCredential?> signInWithGoogle() async {
    if (kIsWeb) {
      // For web, use Firebase Auth directly with Google provider
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      
      // Add required scopes
      googleProvider.addScope('email');
      googleProvider.addScope('profile');
      
      // Set custom parameters
      googleProvider.setCustomParameters({
        'login_hint': 'user@example.com', // Optional
      });
      
      try {
        // Check if Firebase is properly initialized
        if (FirebaseAuth.instance.app.options.apiKey.isEmpty) {
          throw Exception('Firebase not properly configured. Check your firebase_options.dart');
        }
        
        final UserCredential result = await FirebaseAuth.instance.signInWithPopup(googleProvider);
        return result;
      } catch (e) {
        print('Error signing in with Google on web: $e');
        
        // Provide more specific error messages
        if (e.toString().contains('configuration-not-found')) {
          throw Exception('Firebase configuration missing. Please check your Firebase project setup.');
        } else if (e.toString().contains('auth-domain-config-required')) {
          throw Exception('Auth domain not configured. Please add your domain to Firebase authorized domains.');
        } else if (e.toString().contains('popup-blocked')) {
          throw Exception('Popup was blocked by browser. Please allow popups for this site.');
        }
        
        rethrow;
      }
    } else {
      // For mobile platforms, use google_sign_in package
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: '433978378719-qgm0sa7c0uatgbqqckugtvms0cbd4gte.apps.googleusercontent.com',
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      if (googleUser == null || googleAuth == null) return null;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return FirebaseAuth.instance.signInWithCredential(credential);
    }
  }

  static Future<UserCredential?> signInWithFacebook() async {
    if (kIsWeb) {
      // For web, use Firebase Auth directly with Facebook provider
      FacebookAuthProvider facebookProvider = FacebookAuthProvider();
      
      // Optional: Add additional scopes
      facebookProvider.addScope('email');
      facebookProvider.addScope('public_profile');
      
      try {
        final UserCredential result = await FirebaseAuth.instance.signInWithPopup(facebookProvider);
        return result;
      } catch (e) {
        print('Error signing in with Facebook on web: $e');
        return null;
      }
    } else {
      // For mobile platforms, use flutter_facebook_auth package
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final OAuthCredential facebookAuthCredential =
            FacebookAuthProvider.credential(result.accessToken!.token);
        return await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
      }
      return null;
    }
  }


}