import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';
import 'dart:async';

class RecordVideoWidget extends StatefulWidget {
  final Function(String) onRecordingComplete;

  const RecordVideoWidget({super.key, required this.onRecordingComplete});

  @override
  State<RecordVideoWidget> createState() => _RecordVideoWidgetState();
}

class _RecordVideoWidgetState extends State<RecordVideoWidget> {
  CameraController? _cameraController;
  bool _isRecording = false;
  bool _cameraInitialized = false;
  Timer? _timer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      await Permission.camera.request();
      final cameras = await availableCameras();
      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
      );
      await _cameraController?.initialize();
      setState(() {
        _cameraInitialized = true;
      });
    } catch (e) {
      print('Error initializing camera: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to initialize camera')),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cameraController?.dispose();
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
    try {
      await _cameraController?.startVideoRecording();
      setState(() {
        _isRecording = true;
      });
      _startTimer();
    } catch (e) {
      print('Error starting video recording: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to start recording')),
      );
    }
  }

  Future<void> _stopRecording() async {
    try {
      final videoFile = await _cameraController?.stopVideoRecording();
      setState(() {
        _isRecording = false;
      });
      _stopTimer();

      if (videoFile != null) {
        widget.onRecordingComplete(videoFile.path);
      }
    } catch (e) {
      print('Error stopping video recording: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to stop recording')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Adjust height to fit content
      children: [
        if (_cameraInitialized &&
            _cameraController != null &&
            _cameraController!.value.isInitialized)
          AspectRatio(
            aspectRatio: 1.0, // Force 1:1 aspect ratio
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8.0),
              ), // Smooth top border
              child: OverflowBox(
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _cameraController!.value.previewSize!.height,
                    height: _cameraController!.value.previewSize!.height,
                    child: CameraPreview(_cameraController!),
                  ),
                ),
              ),
            ),
          )
        else
          AspectRatio(aspectRatio: 1.0, child: Container(color: Colors.black)),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(color: Colors.black),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context); // Close the widget
                },
              ),
              IconButton(
                icon: Icon(
                  _isRecording ? Icons.stop : Icons.videocam,
                  color: _isRecording ? Colors.red : Colors.blue,
                ),
                onPressed: _isRecording ? _stopRecording : _startRecording,
              ),
              Text(
                _isRecording
                    ? '${(_elapsedSeconds ~/ 60).toString().padLeft(2, '0')}:${(_elapsedSeconds % 60).toString().padLeft(2, '0')}'
                    : '00:00',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
