class AppLinkUriParser {
  static String songUriParser(Uri songUri) {
    final uri = songUri;
    if (uri.host.contains('youtube.com') ||
        uri.host.contains('youtu.be') ||
        uri.host.contains('music.youtube.com')) {
      if (uri.queryParameters.containsKey('v')) {
        return uri.queryParameters['v']!;
      } else if (uri.host == 'youtu.be' && uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.first;
      } else if (uri.path == '/watch' && uri.queryParameters.containsKey('v')) {
        return uri.queryParameters['v']!;
      }
    }
    return "invalid";
  }

  static String playlistUrlParser(Uri playlistUri) {
    if (playlistUri.host.endsWith('youtube.com') ||
        playlistUri.host == 'music.youtube.com' ||
        playlistUri.host == 'www.youtube.com') {
      // YouTube/YouTube Music playlist URLs with 'list' parameter
      if (playlistUri.queryParameters.containsKey('list')) {
        return playlistUri.queryParameters['list']!;
      }
    }
    return "invalid";
  }
}
