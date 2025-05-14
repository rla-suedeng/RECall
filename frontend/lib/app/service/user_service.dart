import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:template/app/models/user_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';

Future<UserModel> loginWithEmail({
  required String email,
  required String password,
}) async {
  try {
    final userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;

    if (user != null) {
      final idToken = await user.getIdToken(true);
      await Future.delayed(const Duration(seconds: 1));

      if (idToken != null) {
        await sendIdTokenToBackend(idToken);

        final userModel = await fetchUserInfo(user.uid, idToken);
        if (GetIt.I.isRegistered<UserModel>()) {
          GetIt.I.unregister<UserModel>();
        }
        GetIt.I.registerSingleton<UserModel>(userModel);
        return userModel;
      } else {
        throw Exception("❌ Login Fail: ID token is null.");
      }
    } else {
      throw Exception("❌ Login Fail: no user info");
    }
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      throw Exception('There is no user with that email.');
    } else if (e.code == 'wrong-password') {
      throw Exception('Wrong Password');
    } else {
      throw Exception('Firebase Login Error: ${e.message}');
    }
  } catch (e) {
    throw Exception('Unknown Error: $e');
  }
}

Future<void> sendIdTokenToBackend(String idToken) async {
  final baseUrl = dotenv.env['API_ADDRESS'];
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print("✅ BackEnd Response: ${response.body}");
    } else {
      print("❌ BackEnd Error: ${response.statusCode} - ${response.body}");
    }
  } catch (e) {
    print("BackEnd Fail: $e");
  }
}

Future<UserModel> fetchUserInfo(String uid, String idToken) async {
  final baseUrl = dotenv.env['API_ADDRESS'];
  final response = await http.get(
    Uri.parse('$baseUrl/user'),
    headers: {
      'Authorization': 'Bearer $idToken',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return UserModel.fromJson(data);
  } else {
    throw Exception(
        'Failed to load user info: ${response.statusCode} - ${response.body}');
  }
}
