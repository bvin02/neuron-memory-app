import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../whisper_bindings.dart';
import './audio_recorder_service.dart';

class TranscriptionService {
  final AudioRecorderService _audioRecorderService = AudioRecorderService();
  bool _isRecording = false;
  String? _recordedFilePath;
  
  bool get isRecording => _isRecording;
  String? get recordedFilePath => _recordedFilePath;

  // Initialize the recorder and make sure whisper model is available
  Future<bool> initialize() async {
    final hasPermission = await _audioRecorderService.initRecorder();
    
    // Ensure the model is available
    await _ensureWhisperModel();
    
    return hasPermission;
  }
  
  // Start recording
  Future<bool> startRecording() async {
    if (_isRecording) {
      return false;
    }
    
    final success = await _audioRecorderService.startRecording();
    _isRecording = success;
    return success;
  }
  
  // Stop recording and transcribe
  Future<String?> stopRecordingAndTranscribe() async {
    if (!_isRecording) {
      return null;
    }
    
    // Stop recording
    final audioPath = await _audioRecorderService.stopRecording();
    _isRecording = false;
    
    if (audioPath == null) {
      return null;
    }
    
    _recordedFilePath = audioPath;
    
    try {
      // Get the path to the whisper model
      final modelPath = await _getWhisperModelPath();
      
      // Since we're now recording directly in WAV format optimized for Whisper,
      // we can use the audio file directly
      final transcription = transcribeAudio(modelPath, audioPath);
      
      return transcription;
    } catch (e) {
      print('Error in transcription process: $e');
      return null;
    }
  }
  
  // Get the path to the whisper model
  Future<String> _getWhisperModelPath() async {
    final docsDir = await getApplicationDocumentsDirectory();
    return path.join(docsDir.path, 'whisper', 'ggml-tiny.bin');
  }
  
  // Ensure the whisper model is available
  Future<void> _ensureWhisperModel() async {
    final modelPath = await _getWhisperModelPath();
    final modelFile = File(modelPath);
    
    if (await modelFile.exists()) {
      // Model already exists
      return;
    }
    
    // Create directory if needed
    final modelDir = Directory(path.dirname(modelPath));
    if (!await modelDir.exists()) {
      await modelDir.create(recursive: true);
    }
    
    try {
      // Copy the model from assets to the app's document directory
      final ByteData data = await rootBundle.load('assets/models/ggml-tiny.bin');
      final buffer = data.buffer;
      await modelFile.writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes)
      );
    } catch (e) {
      print('Error copying whisper model: $e');
      // If the model doesn't exist in assets, you need to download it or add it
      throw Exception('Whisper model not found. Please add it to assets/models/ggml-tiny.bin');
    }
  }
  
  void dispose() {
    _audioRecorderService.dispose();
  }
} 