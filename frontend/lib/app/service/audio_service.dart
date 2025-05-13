import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  AudioPlayer? _player;

  Future<void> requestMicPermission() async {
    final status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  Future<void> startRecording() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
      if (!status.isGranted) {
        throw Exception("🎤 Mic Premission required.");
      }
    }

    if (!_recorder.isStopped) {
      await _recorder.stopRecorder();
    }
    await _recorder.openRecorder();
    await _recorder.startRecorder(toFile: 'audio.aac');
  }

  Future<Uint8List> stopRecordingAndGetBytes() async {
    final path = await _recorder.stopRecorder();
    if (path == null) {
      throw Exception("Cannot find record file path.");
    }

    final file = File(path);
    if (!file.existsSync()) {
      throw Exception("No exist record file.");
    }

    return await file.readAsBytes();
  }

  Future<void> playAudioBytes(Uint8List bytes) async {
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/response.mp3';
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    _player?.dispose();
    _player = AudioPlayer();

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
