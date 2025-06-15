class DirNotExistsException implements Exception {
  final String message;
  DirNotExistsException([this.message = "Directory not exist"]);
  @override
  String toString() => message;
}
