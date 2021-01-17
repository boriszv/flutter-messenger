import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'iimage_compressing_service.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageCompressingService implements IImageCompressingService {

  @override 
  Future<File> compressImage(File file, int quality) async {
    return await compressImagePath(file.path, quality);
  }

  @override
  Future<File> compressImagePath(String path, int quality) async {
    final newPath = join((await getTemporaryDirectory()).path, '${DateTime.now()}.${extension(path)}');

    final result = await FlutterImageCompress.compressAndGetFile(
      path,
      newPath,
      quality: quality,
    );

    return result;
  }
}
