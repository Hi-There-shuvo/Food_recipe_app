import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class authprovider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  User? get user => _auth.currentUser;
  bool get isLoading => _isLoading;

  Future<void> register(String name, String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.sendEmailVerification();
      //print("Please verify your email from your inbox.");
      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      print('$e');
      notifyListeners();
      rethrow;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> checkEmailVerificationAndSaveData(
      String uid, String Name, String email) async {
    await FirebaseAuth.instance.currentUser?.reload();
    bool isverified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;

    if (isverified) {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': Name,
        'email': email,
        'profilePictureUrl': null,
      });
    } else {
      throw Exception("Email is still not Valid");
    }
  }

  Future<void> logIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      print('$e');
      rethrow;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logOut() async {
    try {
      _isLoading = true;
      notifyListeners();
      await _auth.signOut();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
