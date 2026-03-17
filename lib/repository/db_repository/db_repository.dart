import 'package:firebase_auth/firebase_auth.dart';
import 'package:nex_music/model/artistmodel.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/network_provider/home_data/db_network_provider.dart';
import 'package:nex_music/network_provider/home_data/favorites_db_provider.dart';
import 'package:nex_music/network_provider/home_data/playlist_db_provide.dart';
import 'package:nex_music/network_provider/home_data/saved_artists_db_provider.dart';
import 'package:nex_music/network_provider/home_data/search_history_db_provider.dart';
import 'package:nex_music/model/user_playlist_model.dart';

class DbRepository {
  final DbNetworkProvider _dbDataProvider;
  final FavoritesDBProvider _favoritesDBProvider;
  final PlaylistDbProvider _playlistDbProvider;
  final SavedArtistsDBProvider _savedArtistsDBProvider;
  final SearchHistoryDBProvider _searchHistoryDBProvider;

  DbRepository({
    required DbNetworkProvider dbDataProvider,
    required FavoritesDBProvider favoritesDBProvider,
    required PlaylistDbProvider playlistDbProvider,
    required SavedArtistsDBProvider savedArtistsDBProvider,
    required SearchHistoryDBProvider searchHistoryDBProvider,
  })  : _dbDataProvider = dbDataProvider,
        _favoritesDBProvider = favoritesDBProvider,
        _playlistDbProvider = playlistDbProvider,
        _savedArtistsDBProvider = savedArtistsDBProvider,
        _searchHistoryDBProvider = searchHistoryDBProvider;

  //Add recent Played
  Future<void> addToRecentPlayedCollection(Songmodel songData) async {
    await _dbDataProvider.addToRecentPlayedCollection(songData.toJson());
  }

  //Get recent Played
  Stream<List<Songmodel>> getRecentPlayed() {
    final recentPlayedStream = _dbDataProvider.getRecentPlayed();
    return recentPlayedStream.map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return Songmodel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<void> deleteRecentPlayedSong(String vId) async {
    await _dbDataProvider.deleteRecentPlayedSong(vId);
  }

  //Favorites

  //add
  Future<void> addToFavorites(Songmodel song) async {
    try {
      await _favoritesDBProvider.addToFavorites(song.toJson());
    } on FirebaseAuthException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  //exists
  Future<bool> getIsFavorites(String vId) async {
    try {
      return await _favoritesDBProvider.getIsFavorites(vId);
    } on FirebaseAuthException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  //remove
  Future<void> removeFromFavorites(String vId) async {
    try {
      return await _favoritesDBProvider.deleteFromFavorites(vId);
    } on FirebaseAuthException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  //get favorites
  Stream<List<Songmodel>> getFavorites() {
    final favSongsStream = _favoritesDBProvider.getFavorites();
    return favSongsStream.map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return Songmodel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  //playlistDbProvider

  Future<void> createPlaylistCollection(
    String playlistName, {
    String description = '',
    int colorValue = 0xFFE53935,
    String displayMode = 'color',
    bool isPublic = false,
  }) async {
    try {
      await _playlistDbProvider.createUserPlaylistCollection(
        playlistName,
        description: description,
        colorValue: colorValue,
        displayMode: displayMode,
        isPublic: isPublic,
      );
    } on FirebaseAuthException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  //get user playlists - returns full metadata with enriched thumbnails for dynamic mode
  Stream<List<UserPlaylistModel>> getUserPlaylist() {
    final data = _playlistDbProvider.getUserPlaylists();
    return data.asyncMap((querySnapshot) async {
      final List<UserPlaylistModel> playlists = [];
      
      for (var doc in querySnapshot.docs) {
        final docData = doc.data() as Map<String, dynamic>? ?? {};
        List<String> thumbnails = [];

        if (docData['displayMode'] == 'dynamic') {
          try {
            // Fetch thumbnails for dynamic playlists
            final songStream = getUserPlaylistSongs(doc.id);
            final songs = await songStream.first;
            thumbnails = songs
                .take(4)
                .map((s) => s.thumbnail)
                .where((t) => t.isNotEmpty)
                .toList();
          } catch (_) {
            thumbnails = [];
          }
        }
        
        playlists.add(UserPlaylistModel.fromMap(doc.id, docData, thumbnails: thumbnails));
      }
      return playlists;
    });
  }

  //add
  Future<void> addSongToPlaylist(
      String playlistName, Songmodel songdata) async {
    try {
      await _playlistDbProvider.addSongToPlaylist(
          playlistName, songdata.toJson());
    } on FirebaseAuthException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  //get UserPlaylist songs
  Stream<List<Songmodel>> getUserPlaylistSongs(String playlistName) {
    final data = _playlistDbProvider.getUserPlaylistSongs(playlistName);
    return data.map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return Songmodel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  //delete user playlist
  Future<void> deleteUserPlaylist(String playlistName) async {
    try {
      await _playlistDbProvider.deleteUserPlaylist(playlistName);
    } on FirebaseAuthException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  //delete song from the user playlist
  Future<void> deleteSongUserPlaylist(String playlistName, vId) async {
    try {
      await _playlistDbProvider.deleteSongUserPlaylist(playlistName, vId);
    } on FirebaseAuthException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  // ─── PUBLIC PLAYLISTS ──────────────────────────────────────────────────

  Future<void> createPublicPlaylist(
    String playlistName, {
    String description = '',
    int colorValue = 0xFFE53935,
    String displayMode = 'color',
  }) async {
    try {
      await _playlistDbProvider.createPublicPlaylist(
        playlistName,
        description: description,
        colorValue: colorValue,
        displayMode: displayMode,
      );
    } on FirebaseAuthException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> deletePublicPlaylist(String playlistName) async {
    try {
      await _playlistDbProvider.deletePublicPlaylist(playlistName);
    } on FirebaseAuthException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  // Saved Artists

  // Add artist to saved artists
  Future<void> addToSavedArtists(ArtistModel artist) async {
    try {
      await _savedArtistsDBProvider.addToSavedArtists(artist.toJson());
    } on FirebaseAuthException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  // Check if artist is saved
  Future<bool> isArtistSaved(String artistId) async {
    try {
      return await _savedArtistsDBProvider.isArtistSaved(artistId);
    } on FirebaseAuthException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  // Remove artist from saved artists
  Future<void> removeFromSavedArtists(String artistId) async {
    try {
      await _savedArtistsDBProvider.removeFromSavedArtists(artistId);
    } on FirebaseAuthException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  // Get saved artists
  Stream<List<ArtistModel>> getSavedArtists() {
    final savedArtistsStream = _savedArtistsDBProvider.getSavedArtists();
    return savedArtistsStream.map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return ArtistModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Search History

  // Add search query to history
  Future<void> addSearchQuery(String query) async {
    try {
      await _searchHistoryDBProvider.addSearchQuery(query);
    } on FirebaseAuthException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  // Get search history
  Stream<List<String>> getSearchHistory() {
    final searchHistoryStream = _searchHistoryDBProvider.getSearchHistory();
    return searchHistoryStream.map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['query'] as String;
      }).toList();
    });
  }

  // Delete a specific search query
  Future<void> deleteSearchQuery(String query) async {
    try {
      await _searchHistoryDBProvider.deleteSearchQuery(query);
    } on FirebaseAuthException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  // Clear all search history
  Future<void> clearAllSearchHistory() async {
    try {
      await _searchHistoryDBProvider.clearAll();
    } on FirebaseAuthException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }
}
