import 'dart:io';

import 'package:image_cropper/image_cropper.dart';

import 'iimage_cropping_service.dart';

class ImageCroppingService implements IImageCroppingService {

  Future<File> cropImage(String path, double ratioX, double ratioY) {
    return ImageCropper.cropImage(sourcePath: path, aspectRatio: CropAspectRatio(ratioX: ratioX, ratioY: ratioY));
  }
}
