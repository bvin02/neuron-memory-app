import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class AudioRecorderService {
  final _audioRecorder = Record();
  bool _isRecording = false;
  String? _recordedFilePath;

  bool get isRecording => _isRecording;
  String? get recordedFilePath => _recordedFilePath;

  Future<bool> initRecorder() async {
    try {
      final hasPermission = await _audioRecorder.hasPermission();
      return hasPermission;
    } catch (e) {
      print('Error initializing recorder: $e');
      return false;
    }
  }

  Future<bool> startRecording() async {
    if (_isRecording) {
      return false; // Already recording
    }

    try {
      if (await _audioRecorder.hasPermission()) {
        // Get the app documents directory for more permanent storage
        final directory = await getApplicationDocumentsDirectory();
        
        // Create a recordings directory if it doesn't exist
        final recordingsDir = Directory('${directory.path}/recordings');
        if (!await recordingsDir.exists()) {
          await recordingsDir.create(recursive: true);
        }
        
        // Format the current date and time for the filename
        final now = DateTime.now();
        final formattedDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-${now.second.toString().padLeft(2, '0')}';
        
        // Use WAV format instead of m4a
        final filePath = '${recordingsDir.path}/recording_$formattedDate.wav';
        _recordedFilePath = filePath;
        
        // Configure recording options for Whisper compatibility
        await _audioRecorder.start(
          path: filePath,
          encoder: AudioEncoder.wav,       // Use WAV format
          bitRate: 256000,                 // Higher bitrate for better quality
          samplingRate: 16000,             // 16kHz is optimal for Whisper
          numChannels: 1,                  // Mono audio (single channel)
        );
        
        _isRecording = true;
        return true;
      } else {
        print('Microphone permission not granted');
        return false;
      }
    } catch (e) {
      print('Error starting recording: $e');
      _isRecording = false;
      return false;
    }
  }

  Future<String?> stopRecording() async {
    try {
      if (_isRecording) {
        final path = await _audioRecorder.stop();
        _isRecording = false;
        return path;
      }
      return null;
    } catch (e) {
      print('Error stopping recording: $e');
      _isRecording = false;
      return null;
    }
  }

  void dispose() {
    _audioRecorder.dispose();
  }
} 