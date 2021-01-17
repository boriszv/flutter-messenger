import 'dart:io';

abstract class IImageCompressingService {
  Future<File> compressImagePath(String path, int quality);
  Future<File> compressImage(File file, int quality);
}