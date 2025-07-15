import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'
    as http_parser; // Added import for http_parser
import 'dart:convert';

class VideoCallRequestPage extends StatefulWidget {
  // final int chatId;
  // final String friendName;
  // final int friendId;

  // VideoCallRequestPage({
  //   // required this.chatId,
  //   // required this.friendName,
  //   // required this.friendId,
  // });

  @override
  _VideoCallRequestPageState createState() => _VideoCallRequestPageState();
}

class _VideoCallRequestPageState extends State<VideoCallRequestPage> {
  CameraController? _cameraController;
  bool _isInitialized = false;
  bool _isCameraOn = true;
  String _detectedEmotion = "Detecting...";

  // Store available cameras and the currently selected index
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Get the available cameras from the camera package.
    _cameras = await availableCameras();
    if (_cameras.isEmpty) {
      print("No cameras available");
      return;
    }
    _selectedCameraIndex = 0; // Start with the first camera
    _cameraController = CameraController(
      _cameras[_selectedCameraIndex],
      ResolutionPreset.high,
    );

    await _cameraController!.initialize();
    setState(() {
      _isInitialized = true;
    });

    // Start capturing frames for emotion detection.
    _startEmotionDetection();
  }

  // New method to flip between cameras.
  Future<void> _flipCamera() async {
    if (_cameras.length < 2) {
      print("Only one camera available.");
      return;
    }
    // Toggle the index between available cameras.
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _cameraController?.dispose();
    _cameraController = CameraController(
      _cameras[_selectedCameraIndex],
      ResolutionPreset.high,
    );
    await _cameraController!.initialize();
    setState(() {
      // State updated to reflect the new camera.
    });
  }

  Future<void> _captureFrameAndAnalyze() async {
    try {
      // Capture a picture from the camera.
      final XFile picture = await _cameraController!.takePicture();
      final bytes = await picture.readAsBytes();

      // Decode the image using the image package.
      final image = img.decodeImage(bytes);

      if (image != null) {
        // Convert the image back to JPEG format.
        final jpegData = Uint8List.fromList(img.encodeJpg(image));
        await _sendImageToFlask(jpegData);
      }
    } catch (e) {
      print("Error capturing frame: $e");
    }
  }

  Future<void> _sendImageToFlask(Uint8List imageBytes) async {
    // Replace with your actual Flask server IP address.
    final uri = Uri.parse("http://192.168.1.16:5001/analyze_frame");

    // Create a multipart request and attach the image.
    final request = http.MultipartRequest("POST", uri)
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: "frame.jpg",
        contentType: http_parser.MediaType('image', 'jpeg'),
      ));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseData);
        setState(() {
          _detectedEmotion = jsonResponse['dominant_emotion'];
        });
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error sending image to Flask: $e");
    }
  }

  void _startEmotionDetection() {
    Future.delayed(Duration(seconds: 5), () async {
      if (_isInitialized) {
        await _captureFrameAndAnalyze();
        _startEmotionDetection();
      }
    });
  }

  void _toggleCamera() {
    if (_cameraController != null) {
      setState(() {
        _isCameraOn = !_isCameraOn;
        if (_isCameraOn) {
          // Start the image stream if the camera is turned on.
          _cameraController!.startImageStream((image) {});
        } else {
          // Stop the image stream if the camera is turned off.
          _cameraController!.stopImageStream();
        }
      });
    }
  }

  void _rejectCall() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(widget.friendName,
            //     style: TextStyle(
            //         color: Colors.white,
            //         fontWeight: FontWeight.bold,
            //         fontSize: 20)),
            Text("Calling...",
                style: TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: _isInitialized
                ? CameraPreview(
                    _cameraController!) // Provided by the camera package
                : CircularProgressIndicator(),
          ),
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Emotion: $_detectedEmotion",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    backgroundColor: Colors.black54),
              ),
            ),
          ),
          // Button to flip the camera
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _flipCamera,
                icon: Icon(Icons.flip_camera_android),
                label: Text("Flip Camera"),
              ),
            ),
          ),
          // Call controls (end call and toggle camera)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                    onPressed: _rejectCall,
                    icon: Icon(Icons.call_end, color: Colors.red, size: 50)),
                IconButton(
                    onPressed: _toggleCamera,
                    icon: Icon(
                        _isCameraOn ? Icons.videocam : Icons.videocam_off,
                        color: Colors.blue,
                        size: 50)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
