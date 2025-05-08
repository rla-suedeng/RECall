import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class FirebaseStorageService {
  final _storage = FirebaseStorage.instance;
  final _picker = ImagePicker();

  /// 유저 ID를 전달받아, 해당 유저 전용 경로에 업로드
  Future<String?> pickAndUploadImage({required String userId}) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return null;

    final file = File(pickedFile.path);
    final fileName = path.basename(file.path);

    try {
      // ✅ 유저별 디렉토리 경로 지정
      final ref = _storage.ref().child('uploads/$userId/$fileName');
      await ref.putFile(file);

      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('❌ 이미지 업로드 실패: $e');
      return null;
    }
  }
}
