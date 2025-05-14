import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class FirebaseStorageService {
  final _storage = FirebaseStorage.instance;
  final _picker = ImagePicker();

  Future<String?> pickAndUploadImage({required String userId}) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return null;

    final file = File(pickedFile.path);
    final fileName = path.basename(file.path);

    try {
      final ref = _storage.ref().child('uploads/$userId/$fileName');
      await ref.putFile(file);

      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('❌ Image Upload Fail: $e');
      return null;
    }
  }
}
