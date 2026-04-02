import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  StreamSubscription<Position>? _positionStream;

  double? latitude;
  double? longitude;
  double? accuracy;
  double? speed;
  double? altitude;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _startLocationTracking();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller!.initialize();
    setState(() {});
  }

  void _startLocationTracking() async {
    await Geolocator.requestPermission();

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1,
      ),
    ).listen((Position position) {
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
        accuracy = position.accuracy;
        speed = position.speed;
        altitude = position.altitude;
      });
    });
  }

  Future<void> _captureAndSend() async {
    if (_controller == null) return;

    await _initializeControllerFuture;
    final image = await _controller!.takePicture();

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("http://YOUR_IP:8000/report"),
    );

    request.fields['latitude'] = latitude?.toString() ?? "";
    request.fields['longitude'] = longitude?.toString() ?? "";
    request.fields['accuracy'] = accuracy?.toString() ?? "";
    request.fields['speed'] = speed?.toString() ?? "";
    request.fields['altitude'] = altitude?.toString() ?? "";

    request.files.add(
      await http.MultipartFile.fromPath('image', image.path),
    );

    await request.send();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Survey Submitted")),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initializeControllerFuture == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [

                // 📷 Camera (Top)
                Expanded(
                  flex: 3,
                  child: CameraPreview(_controller!),
                ),

                // 📋 Large White Panel (Bottom)
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "FIELD SURVEY DATA",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: 1,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // Left Column
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Latitude:",
                                      style: TextStyle(fontWeight: FontWeight.w600)),
                                  Text(latitude?.toStringAsFixed(6) ?? "--"),
                                  const SizedBox(height: 15),

                                  const Text("Longitude:",
                                      style: TextStyle(fontWeight: FontWeight.w600)),
                                  Text(longitude?.toStringAsFixed(6) ?? "--"),
                                ],
                              ),
                            ),

                            // Right Column
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Accuracy:",
                                      style: TextStyle(fontWeight: FontWeight.w600)),
                                  Text("±${accuracy?.toStringAsFixed(2) ?? "--"} m"),
                                  const SizedBox(height: 15),

                                  const Text("Speed:",
                                      style: TextStyle(fontWeight: FontWeight.w600)),
                                  Text("${(speed ?? 0).toStringAsFixed(2)} m/s"),
                                  const SizedBox(height: 15),

                                  const Text("Altitude:",
                                      style: TextStyle(fontWeight: FontWeight.w600)),
                                  Text("${altitude?.toStringAsFixed(2) ?? "--"} m"),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1565C0),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            onPressed: _captureAndSend,
                            child: const Text(
                              "CAPTURE & SUBMIT",
                              style: TextStyle(letterSpacing: 1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}