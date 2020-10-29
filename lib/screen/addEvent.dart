import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class addEvent extends StatefulWidget {
  @override
  _addEvent createState() => _addEvent();
}

class _addEvent extends State<addEvent> {

  CameraController _controller;
  Future<void> _initializeControllerFuture;
  bool isCameraReady = false;
  bool showCapturedPhoto = false;
  var ImagePath;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _controller = CameraController(firstCamera,ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
    if (!mounted) {
      return;
    }
    setState(() {
      isCameraReady = true;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller != null
          ? _initializeControllerFuture = _controller.initialize()
          : null; //on pause camera is disposed, so we need to call again "issue is only for android"
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('CleanWay')),
        backgroundColor: Colors.green,
      ),
    body:
      Center(
        child: Column(
          children: <Widget> [
            new FloatingActionButton(
              onPressed: () {
                onCaptureButtonPressed();
                FutureBuilder<void>(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Transform.scale(
                          scale: _controller.value.aspectRatio / deviceRatio,
                          child: Center(
                            child: AspectRatio(
                              aspectRatio: _controller.value.aspectRatio,
                              child: CameraPreview(_controller), //cameraPreview
                            ),
                          ));
                    } else {
                      return Center(
                          child:
                          CircularProgressIndicator()); // Otherwise, display a loading indicator.
                    }
                    },
                );
                },
            ),
            Center(
              child: Image.file(
                  File(ImagePath)
              ),
            )
          ],
        ),
      ),
    );
  }
  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void onCaptureButtonPressed() async {  //on camera button press
    try {
      var prd = await getTemporaryDirectory();
      final path = prd.path;
      ImagePath = path;
      print(path);
      await _controller.takePicture(path); //take photo

      setState(() {
        showCapturedPhoto = true;
      });
    } catch (e) {
      print(e);
    }
  }

}
