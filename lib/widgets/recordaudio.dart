import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

class RecordAudioWidget extends StatefulWidget {
  final Function(String) onRecordingComplete;

  const RecordAudioWidget({super.key, required this.onRecordingComplete});

  @override
  State<RecordAudioWidget> createState() => _RecordAudioWidgetState();
}

class _RecordAudioWidgetState extends State<RecordAudioWidget> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  bool _isPaused = false;
  String _recordingFilePath = '';
  Timer? _timer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.closeRecorder();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _elapsedSeconds = 0;
    });
  }

  Future<void> _startRecording() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath =
        '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';
    await _recorder.startRecorder(toFile: filePath);
    setState(() {
      _isRecording = true;
      _isPaused = false;
      _recordingFilePath = filePath;
    });
    _startTimer();
  }

  Future<void> _pauseRecording() async {
    await _recorder.pauseRecorder();
    setState(() {
      _isPaused = true;
    });
  }

  Future<void> _resumeRecording() async {
    await _recorder.resumeRecorder();
    setState(() {
      _isPaused = false;
    });
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
      _isPaused = false;
    });
    _stopTimer();

    // Verify file was created
    final file = File(_recordingFilePath);
    final exists = await file.exists();
    print('Audio recording stopped, file path: $_recordingFilePath');
    print('File exists after recording: $exists');
    if (exists) {
      final size = await file.length();
      print('Audio file size: $size bytes');
    }

    widget.onRecordingComplete(_recordingFilePath);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8.0),
          topRight: Radius.circular(8.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              if (_isRecording) {
                _stopRecording();
              }
              Navigator.pop(context); // Hide the widget
            },
          ),
          IconButton(
            icon: Icon(
              _isRecording && !_isPaused ? Icons.pause : Icons.mic,
              color: _isRecording ? Colors.red : Colors.blue,
            ),
            onPressed: _isRecording && !_isPaused
                ? _pauseRecording
                : _isRecording && _isPaused
                ? _resumeRecording
                : _startRecording,
          ),
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _isRecording ? _stopRecording : null,
          ),
          Text(
            _isRecording
                ? '${(_elapsedSeconds ~/ 60).toString().padLeft(2, '0')}:${(_elapsedSeconds % 60).toString().padLeft(2, '0')}'
                : '00:00',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
