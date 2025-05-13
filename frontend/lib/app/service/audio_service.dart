import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  AudioPlayer? _player;

  /// 마이크 권한을 요청합니다.
  Future<void> requestMicPermission() async {
    final status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  /// 녹음을 시작합니다.
  Future<void> startRecording() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
      if (!status.isGranted) {
        throw Exception("🎤 마이크 권한이 필요합니다.");
      }
    }

    if (!_recorder.isStopped) {
      await _recorder.stopRecorder();
    }
    await _recorder.openRecorder();
    await _recorder.startRecorder(toFile: 'audio.aac');
  }

  /// 녹음을 멈추고 byte 배열을 반환합니다.
  Future<Uint8List> stopRecordingAndGetBytes() async {
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

  /// 오디오 byte 데이터를 재생합니다. (iOS 대응: 임시 파일로 처리)
  // Future<void> playAudioBytes(Uint8List bytes) async {
  //   final tempDir = await getTemporaryDirectory();
  //   final filePath = '${tempDir.path}/response.mp3';
  //   final file = File(filePath);
  //   await file.writeAsBytes(bytes);

  //   // 플레이어 새로 생성 (녹음 중 충돌 방지)
  //   _player?.dispose();
  //   _player = AudioPlayer();

  //   await _player!.setVolume(1.0);
  //   await _player!.play(DeviceFileSource(filePath));
  // }

  // /// 자원 정리
  // void dispose() {
  //   _recorder.closeRecorder();
  //   _player?.dispose();
  // }
  Future<void> playAudioBytes(Uint8List bytes) async {
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/response.mp3';
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    // 플레이어 새로 생성 (녹음 중 충돌 방지)
    _player?.dispose();
    _player = AudioPlayer();

    // ✅ 오디오 세션 설정 추가 (녹화 중 소리 포함)
    await _player!.setAudioContext(const AudioContext(
      android: AudioContextAndroid(
        isSpeakerphoneOn: true,
        stayAwake: false,
        contentType: AndroidContentType.speech,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.gain,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playAndRecord,
        options: [AVAudioSessionOptions.defaultToSpeaker],
      ),
    ));

    await _player!.setVolume(1.0);
    await _player!.play(DeviceFileSource(filePath));
  }
}
