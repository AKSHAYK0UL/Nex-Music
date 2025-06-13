class SongRawData {
  final Uri url;
  final List<String> codecs;
  final int totalBytes;

  SongRawData(
      {required this.url, required this.codecs, required this.totalBytes});
}
