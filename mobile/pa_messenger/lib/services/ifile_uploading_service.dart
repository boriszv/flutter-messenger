abstract class IFileUploadingService {
  Future<String> uploadFileAndGetUrl(String path, {String pathToUploadTo, String contentType});
}
