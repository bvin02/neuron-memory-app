import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Record Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const RecordTestPage(),
    );
  }
}

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
        // Get the temporary directory
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        _recordedFilePath = filePath;
        
        // Configure recording options
        await _audioRecorder.start(
          path: filePath,
          encoder: AudioEncoder.AAC,
          bitRate: 128000,
          samplingRate: 44100,
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

class RecordTestPage extends StatefulWidget {
  const RecordTestPage({super.key});

  @override
  _RecordTestPageState createState() => _RecordTestPageState();
}

class _RecordTestPageState extends State<RecordTestPage> {
  final _audioService = AudioRecorderService();
  bool _isRecording = false;
  String? _recordedFilePath;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  Future<void> _initRecorder() async {
    await _audioService.initRecorder();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _audioService.stopRecording();
      setState(() {
        _isRecording = false;
        if (path != null) {
          _recordedFilePath = path;
          print('Recording saved to: $path');
        }
      });
    } else {
      final success = await _audioService.startRecording();
      if (success) {
        setState(() {
          _isRecording = true;
          print('Started recording');
        });
      } else {
        print('Failed to start recording');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isRecording ? 'Recording...' : 'Not Recording',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleRecording,
              child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
            ),
            if (_recordedFilePath != null) ...[
              const SizedBox(height: 20),
              Text('Last recording: $_recordedFilePath'),
            ]
          ],
        ),
      ),
    );
  }
} 