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

class RecordTestPage extends StatefulWidget {
  const RecordTestPage({super.key});

  @override
  _RecordTestPageState createState() => _RecordTestPageState();
}

class _RecordTestPageState extends State<RecordTestPage> {
  final _audioRecorder = Record();
  bool _isRecording = false;
  String? _recordedFilePath;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _initRecorder() async {
    try {
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        print('Microphone permission not granted');
      }
    } catch (e) {
      print('Error initializing recorder: $e');
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        // Get the temporary directory
        final directory = await getTemporaryDirectory();
        _recordedFilePath = '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        // Start recording with minimal parameters for version 3.0.4
        await _audioRecorder.start(
          path: _recordedFilePath!,
          encoder: AudioEncoder.AAC,
          bitRate: 128000,
          samplingRate: 44100,
        );
        
        setState(() {
          _isRecording = true;
        });
        
        print('Started recording to: $_recordedFilePath');
      } else {
        print('Microphone permission not granted');
      }
    } catch (e) {
      print('Error starting recording: $e');
      setState(() {
        _isRecording = false;
      });
    }
  }

  Future<void> _stopRecording() async {
    try {
      if (_isRecording) {
        final path = await _audioRecorder.stop();
        setState(() {
          _isRecording = false;
        });
        
        if (path != null) {
          print('Recording saved to: $path');
        } else {
          print('Recording stopped but no file path returned');
        }
      }
    } catch (e) {
      print('Error stopping recording: $e');
      setState(() {
        _isRecording = false;
      });
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
              onPressed: _isRecording ? _stopRecording : _startRecording,
              child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
            ),
          ],
        ),
      ),
    );
  }
} 