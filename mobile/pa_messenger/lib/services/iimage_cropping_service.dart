
import 'dart:io';

abstract class IImageCroppingService {
  Future<File> cropImage(String path, double ratioX, double ratioY);
}
