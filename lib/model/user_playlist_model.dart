
class UserPlaylistModel {
  final String name;
  final String description;
  final int colorValue;
  final String displayMode;
  final bool isPublic;
  final List<String> thumbnails;
  final dynamic timestamp;

  UserPlaylistModel({
    required this.name,
    required this.description,
    required this.colorValue,
    required this.displayMode,
    required this.isPublic,
    this.thumbnails = const [],
    this.timestamp,
  });

  factory UserPlaylistModel.fromMap(String id, Map<String, dynamic> data, {List<String> thumbnails = const []}) {
    return UserPlaylistModel(
      name: id,
      description: data['description'] ?? '',
      colorValue: data['colorValue'] ?? 0xFFE53935,
      displayMode: data['displayMode'] ?? 'color',
      isPublic: data['isPublic'] ?? false,
      thumbnails: thumbnails.isNotEmpty ? thumbnails : (data['thumbnails'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      timestamp: data['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'colorValue': colorValue,
      'displayMode': displayMode,
      'isPublic': isPublic,
      'thumbnails': thumbnails,
      'timestamp': timestamp,
    };
  }

  UserPlaylistModel copyWith({
    String? name,
    String? description,
    int? colorValue,
    String? displayMode,
    bool? isPublic,
    List<String>? thumbnails,
    dynamic timestamp,
  }) {
    return UserPlaylistModel(
      name: name ?? this.name,
      description: description ?? this.description,
      colorValue: colorValue ?? this.colorValue,
      displayMode: displayMode ?? this.displayMode,
      isPublic: isPublic ?? this.isPublic,
      thumbnails: thumbnails ?? this.thumbnails,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
