class FileExistException implements Exception {
  final String message;
  FileExistException([this.message = "File already exists"]);
  @override
  String toString() => message;
}
