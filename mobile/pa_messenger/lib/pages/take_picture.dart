import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:pa_messenger/pages/take_picture_preivew.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class TakePicture extends StatefulWidget {

  const TakePicture({
    Key key,
  }) : super(key: key);

  @override
  TakePictureState createState() => TakePictureState();
}

class TakePictureState extends State<TakePicture> {

  CameraController _controller;
  Future<void> _initializeControllerFuture;
  int selectedCameraIndex = 0;
  List<CameraDescription> _cameraList = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    _cameraList = await availableCameras();
    final firstCamera = _cameraList.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );

    setState(() {
      _initializeControllerFuture = _controller.initialize();
      selectedCameraIndex = 0;
    });
  }

  _switchCamera() {
    if (selectedCameraIndex == _cameraList.length - 1) {
      selectedCameraIndex = 0;
    } else {
      selectedCameraIndex++;
    }

    final camera = _cameraList[selectedCameraIndex];

    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
    );

    setState(() { _initializeControllerFuture = _controller.initialize(); });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _floatingButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Stack(
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) return CameraPreview(_controller);
              return Center(child: CircularProgressIndicator());
            },
          ),

          Positioned(
            child: IconButton(icon: Icon(Icons.switch_camera, color: Colors.white),
              onPressed: () {_switchCamera();},
            ),
            bottom: 20,
            right: 20
          ),
        ],
      ),
    );
  }

  _floatingButton(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.camera_alt),
      onPressed: () async {
        try {
          await _initializeControllerFuture;
          final path = join((await getTemporaryDirectory()).path, '${DateTime.now()}.png');
          await _controller.takePicture(path);

          final result = await Navigator.of(context).pushNamed('/take-picture-preview', arguments: TakePicturePreviewArgs(path));

          if (result) {
            Navigator.of(context).pop(path);
            return;
          }

        } catch (e) {
          print(e);
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}