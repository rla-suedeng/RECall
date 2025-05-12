import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  /// 마이크 권한을 요청하고, 녹음을 시작합니다.
  Future<void> requestMicPermission() async {
    final status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  Future<void> startRecording() async {
    // ✅ 마이크 권한 확인 및 요청
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
      if (!status.isGranted) {
        throw Exception("🎤 마이크 권한이 필요합니다.");
      }
    }

    // ✅ 레코더 초기화
    if (!_recorder.isStopped) {
      await _recorder.stopRecorder();
    }
    await _recorder.openRecorder();
    await _recorder.startRecorder(toFile: 'audio.aac');
  }

  /// 녹음을 멈추고 byte 배열을 반환합니다.
  Future<List<int>> stopRecordingAndGetBytes() async {
    final path = await _recorder.stopRecorder();
    if (path == null) {
      throw Exception("녹음 파일 경로를 찾을 수 없습니다.");
    }

    final file = File(path);
    if (!file.existsSync()) {
      throw Exception("녹음 파일이 존재하지 않습니다.");
    }

    return await file.readAsBytes();
  }

  /// 레코더 자원 해제
  void dispose() {
    _recorder.closeRecorder();
  }
}
