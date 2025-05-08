import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:template/app/constants/api_constants.dart';
import 'package:template/app/models/user_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<UserModel> loginWithEmail({
  required String email,
  required String password,
}) async {
  try {
    // 🔐 Firebase 로그인 시도
    final userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;

    if (user != null) {
      // ✅ 로그인 성공 → ID 토큰 획득
      final idToken = await user.getIdToken();
      print('🔥 로그인 성공, 토큰: $idToken');

      // ✅ 백엔드로 토큰 전송
      if (idToken != null) {
        await sendIdTokenToBackend(idToken);

        final userModel = await fetchUserInfo(user.uid, idToken);
        return userModel;
      } else {
        throw Exception("❌ 로그인 실패: ID 토큰이 null입니다.");
      }
    } else {
      throw Exception("❌ 로그인 실패: 사용자 정보 없음");
    }
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      throw Exception('해당 이메일을 가진 사용자가 없습니다.');
    } else if (e.code == 'wrong-password') {
      throw Exception('비밀번호가 틀렸습니다.');
    } else {
      throw Exception('Firebase 로그인 오류: ${e.message}');
    }
  } catch (e) {
    throw Exception('알 수 없는 오류: $e');
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
      print("✅ 백엔드 응답: ${response.body}");
    } else {
      print("❌ 백엔드 오류: ${response.statusCode} - ${response.body}");
    }
  } catch (e) {
    print("백엔드 요청 실패: $e");
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
