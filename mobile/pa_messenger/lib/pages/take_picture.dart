import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:pa_messenger/pages/take_picture_preivew.dart';
import 'package:pa_messenger/services/iimage_compressing_service.dart';
import 'package:pa_messenger/services/iimage_cropping_service.dart';
import 'package:pa_messenger/services/image_compressing_service.dart';
import 'package:pa_messenger/services/image_cropping_service.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class TakePictureArgs {
  final bool cropImage;

  TakePictureArgs({this.cropImage});
}

class TakePicture extends StatefulWidget {

  @override
  TakePictureState createState() => TakePictureState();
}

class TakePictureState extends State<TakePicture> {

  static final IImageCompressingService _imageCompressor = ImageCompressingService();
  static final IImageCroppingService _imageCroppingService = ImageCroppingService();

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

  _takePicture(BuildContext context) async {
    try {
      await _initializeControllerFuture;

      var path = join((await getTemporaryDirectory()).path, '${DateTime.now()}.png');
      await _controller.takePicture(path);

      final args = ModalRoute.of(context).settings.arguments as TakePictureArgs;

      if (args.cropImage) {
        final fileResult = await _imageCroppingService.cropImage(path, 1, 1);
        if (fileResult == null) return;

        path = fileResult.path;
      }

      path = (await _imageCompressor.compressImagePath(path, 50)).path;

      final result = await Navigator.of(context).pushNamed('/take-picture-preview', arguments: TakePicturePreviewArgs(path));

      if (result != null && result) {
        Navigator.of(context).pop(path);
        return;
      }

    } catch (e) {
      print(e);
    }
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
      onPressed: () { _takePicture(context); },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}