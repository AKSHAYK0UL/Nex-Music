import 'package:nex_music/model/songmodel.dart';

enum PlaylistItemType {
  user,
  radio,
}

class PlaylistItem {
  final Songmodel song;
  final DateTime addedAt;
  final PlaylistItemType type;

  PlaylistItem({
    required this.song,
    required this.addedAt,
    required this.type,
  });

  // Create a user playlist item
  factory PlaylistItem.user(Songmodel song) {
    return PlaylistItem(
      song: song,
      addedAt: DateTime.now(),
      type: PlaylistItemType.user,
    );
  }

  // Create a radio playlist item
  factory PlaylistItem.radio(Songmodel song) {
    return PlaylistItem(
      song: song,
      addedAt: DateTime.now(),
      type: PlaylistItemType.radio,
    );
  }

  // Copy with new timestamp (for updating priority)
  PlaylistItem copyWithNewTimestamp() {
    return PlaylistItem(
      song: song,
      addedAt: DateTime.now(),
      type: type,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlaylistItem && other.song.vId == song.vId;
  }

  @override
  int get hashCode => song.vId.hashCode;

  @override
  String toString() {
    return 'PlaylistItem(song: ${song.songName}, addedAt: $addedAt, type: $type)';
  }
}
