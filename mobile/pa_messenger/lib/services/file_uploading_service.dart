
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:pa_messenger/services/ifile_uploading_service.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:path/path.dart';

class FileUploadingService implements IFileUploadingService {

  Future<String> uploadFileAndGetUrl(String path, { String pathToUploadTo, String contentType }) async {
    if (pathToUploadTo == null || pathToUploadTo.trim().isEmpty) {
      pathToUploadTo = '${DateTime.now()}';
    }

    final segments = split(pathToUploadTo);

    var ref = storage.FirebaseStorage.instance.ref();
    for (final segment in segments) {
      ref = ref.child(segment);
    }

    var metadata = storage.SettableMetadata();
    if (contentType != null && contentType.trim().isNotEmpty) {
      metadata = storage.SettableMetadata(contentType: contentType);
    }

    storage.UploadTask uploadTask;
    if (kIsWeb) {
      throw new Exception('Web not supported at the moment');
      // uploadTask = ref.putData(await file.readAsBytes(), metadata);
    } else {
      uploadTask = ref.putFile(File(path), metadata);
    }

    final result = await uploadTask;
    return result.ref.getDownloadURL();
  }
}
