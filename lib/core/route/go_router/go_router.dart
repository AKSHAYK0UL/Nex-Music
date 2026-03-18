import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_music/model/playlistmodel.dart';
import 'package:nex_music/presentation/audio_books/screens/audiobook_screen.dart';
import 'package:nex_music/presentation/audio_player/screen/audio_player.dart';
import 'package:nex_music/presentation/auth/screens/user_info.dart' as u;
import 'package:nex_music/presentation/favorites/screen/favorites_songs_screen.dart';
import 'package:nex_music/presentation/library/screens/library_screen.dart';
import 'package:nex_music/presentation/home/navbar/screen/navbar_shell.dart';
import 'package:nex_music/presentation/home/screen/home_screen.dart';
import 'package:nex_music/presentation/home/screen/show_all_generic.dart';
import 'package:nex_music/presentation/home/screen/showallalbums.dart';
import 'package:nex_music/presentation/home/screen/showallplaylists.dart';
import 'package:nex_music/model/artistmodel.dart';
import 'package:nex_music/presentation/home/artist/artist_full.dart';
import 'package:nex_music/presentation/playlist/screen/showplaylist.dart';
import 'package:nex_music/presentation/podcast/screens/podcast_screen.dart';
import 'package:nex_music/presentation/recent/screens/recentscreen.dart';
import 'package:nex_music/presentation/saved/screens/saved.dart';
import 'package:nex_music/presentation/saved_artists/screen/saved_artists_screen.dart';
import 'package:nex_music/presentation/search/screens/search_result_tab.dart';
import 'package:nex_music/presentation/search/screens/search_screen.dart';
import 'package:nex_music/presentation/setting/screen/phone_setting.dart';
import 'package:nex_music/presentation/setting/screen/settting.dart';
import 'package:nex_music/presentation/user_playlist/screens/user_playlist.dart';
import 'package:nex_music/presentation/user_playlist/screens/user_playlist_songs.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  // Cache for the router instance
  static GoRouter? _cachedRouter;
  static String? _cachedUserId;

  // Returns a cached router instance if the user hasn't changed,
  // otherwise creates a new router and caches it.
  static GoRouter createRouter(User currentUser) {
    // Return cached router if user hasn't changed
    if (_cachedRouter != null && _cachedUserId == currentUser.uid) {
      return _cachedRouter!;
    }

    // User changed or first time - create new router and cache it
    _cachedUserId = currentUser.uid;
    _cachedRouter = _buildRouter(currentUser);
    return _cachedRouter!;
  }

  static GoRouter get router => _cachedRouter!;

  // Clears the cached router (call this on logout)
  static void clearCache() {
    _cachedRouter = null;
    _cachedUserId = null;
  }

  static GoRouter _buildRouter(User currentUser) {
    return GoRouter(
      initialLocation: RouterPath.homeRoute,
      navigatorKey: rootNavigatorKey,
      routes: <RouteBase>[
        // Shell route with bottom navigation
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return NavBarShell(
              key: ValueKey(navigationShell.currentIndex),
              navigationShell: navigationShell,
            );
          },
          branches: [
            // Home tab
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouterPath.homeRoute,
                  name: RouterName.homeName,
                  builder: (context, state) =>
                      HomeScreen(currentUser: currentUser),
                  routes: [
                    // Nested routes under home tab
                    GoRoute(
                      path: RouterPath.showAllPlaylistsRoute,
                      name: RouterName.showAllPlaylistsName,
                      builder: (context, state) => const ShowAllPlaylists(),
                    ),
                    GoRoute(
                      path: RouterPath.showAllAlbumsRoute,
                      name: RouterName.showAllAlbumsName,
                      builder: (context, state) => const ShowAllAlbums(),
                    ),
                    GoRoute(
                      path: RouterPath.showPlaylistRoute,
                      name: RouterName.showPlaylistName,
                      builder: (context, state) {
                        final playlistData = state.extra as PlayListmodel;
                        return ShowPlaylist(playlistData: playlistData);
                      },
                    ),
                    GoRoute(
                      path: RouterPath.showAllGenericRoute,
                      name: RouterName.showAllGenericName,
                      builder: (context, state) {
                        final extra = state.extra as Map<String, dynamic>;
                        return ShowAllGeneric(
                          title: extra['title'] as String,
                          items: extra['items'] as List<PlayListmodel>,
                          isAlbum: extra['isAlbum'] as bool? ?? false,
                        );
                      },
                    ),
                    GoRoute(
                      path: RouterPath.showPlaylistSongsRoute,
                      name: RouterName.showPlaylistSongsName,
                      builder: (context, state) {
                        final extra = state.extra as PlayListmodel;
                        return ShowPlaylist(
                          playlistData: extra,
                        );
                      },
                    ),
                    GoRoute(
                      path: RouterPath.artistRoute,
                      name: RouterName.artistName,
                      builder: (context, state) {
                        final artist = state.extra as ArtistModel;
                        return ArtistFullScreen(
                          artist: artist,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            // Recent tab
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouterPath.recentRoute,
                  name: RouterName.recentName,
                  builder: (context, state) => const RecentScreen(),
                ),
              ],
            ),
            // Search tab
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouterPath.searchRoute,
                  name: RouterName.searchName,
                  builder: (context, state) {
                    final extra=state.extra as String?;
                    return  SearchScreen(searchText: extra);
                  },
                  routes: [
                    GoRoute(
                      path: RouterPath.searchResultRoute,
                      name: RouterName.searchResultName,
                      builder: (context, state) {
                        final extra = state.extra as String;
                        return SearchResultTab(searchText: extra);
                      },
                    ),
                  ],
                ),
              ],
            ),
            // Library tab
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouterPath.libraryRoute,
                  name: RouterName.libraryName,
                  builder: (context, state) => const LibraryScreen(),
                  routes: [
                    GoRoute(
                      path: RouterPath.libraryUserPlaylistRoute,
                      name: RouterName.libraryUserPlaylistName,
                      builder: (context, state) {
                        return const UserPlaylist();
                      },
                    ),
                    GoRoute(
                      path: RouterPath.userPlaylistSongsRoute,
                      name: RouterName.userPlaylistSongsName,
                      builder: (context, state) {
                        final extra = state.extra;
                        // Support passing string as title or full map for metadata
                        String title = "Playlist";
                        String? imageUrl;
                        int? colorValue;

                        if (extra is String) {
                          title = extra;
                        } else if (extra is Map<String, dynamic>) {
                          title = extra['name'] as String? ?? "Playlist";
                          imageUrl = extra['thumbnail'] as String?;
                          colorValue = extra['colorValue'] as int?;
                        }

                        return UserPlaylistSongs(
                          playlistName: title,
                          thumbnail: imageUrl,
                          colorValue: colorValue,
                        );
                      },
                    ),
                    GoRoute(
                      path: RouterPath.savedArtistRoute,
                      name: RouterName.savedArtistName,
                      builder: (context, state) {
                        return const SavedArtistsScreen();
                      },
                    ),
                    GoRoute(
                      path: RouterPath.favoritesSongsRoute,
                      name: RouterName.favoritesSongsName,
                      builder: (context, state) {
                        return const FavoritesSongsScreen();
                      },
                    ),
                    GoRoute(
                      path: RouterPath.downloadedSongsRoute,
                      name: RouterName.downloadedSongsName,
                      builder: (context, state) {
                        return const SavedSongs(
                          isoffline: false,
                        );
                      },
                    ),
                    GoRoute(
                      path: RouterPath.podcastsRoute,
                      name: RouterName.podcastsName,
                      builder: (context, state) {
                        return const PodcastsScreen();
                      },
                    ),
                    GoRoute(
                      path: RouterPath.audioBooksRoute,
                      name: RouterName.audioBooksName,
                      builder: (context, state) {
                        return const AudiobooksScreen();
                      },
                    ),
                  ],
                ),
              ],
            ),
            // Settings tab
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouterPath.settingsRoute,
                  name: RouterName.settingsName,
                  builder: (context, state) {
                    return Setting(currentUser: currentUser);
                  },
                ),
              ],
            ),
          ],
        ),
        // Full screen routes (without bottom navigation)
        GoRoute(
          path: RouterPath.audioPlayerRoute,
          name: RouterName.audioPlayerName,
          pageBuilder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            print("EXTRAS ############### ${extra} ######################");

            return CustomTransitionPage(
              opaque: false,
              key: state.pageKey,
              child: Builder(
                builder: (context) {
                  return AudioPlayerScreen(routeData: extra!);
                },
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(0.0, 1.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;

                var slideTween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(slideTween),
                  child: child,
                );
              },
            );
          },
        ),

        GoRoute(
          path: RouterPath.offlineDownloadsRoute,
          name: RouterName.offlineDownloadsName,
          builder: (context, state) => const SavedSongs(isoffline: true),
        ),
        GoRoute(
          path: RouterPath.userInfoRoute,
          name: RouterName.userInfoName,
          builder: (context, state) => u.UserInfo(currentUser: currentUser),
        ),
        GoRoute(
          path: RouterPath.qualityRoute,
          name: RouterName.qualityName,
          builder: (context, state) => const QualitySettingsScreen(),
        ),
      ],
    );
  }
}

extension AppRouterExtension on AppRouter {
  // Call this when user logs out to ensure fresh router on next login
  static void onLogout() {
    AppRouter.clearCache();
  }
}

// Path class
class RouterPath {
  // Shell routes (with bottom navigation)
  static const String homeRoute = '/';
  static const String recentRoute = '/recent';
  static const String searchRoute = '/search';
  static const String libraryRoute = '/library';
  static const String settingsRoute = '/settings';

  // Full screen routes (without bottom navigation)
  static const String audioPlayerRoute = '/audio-player';
  // static const String playlistLoadingRoute = '/playlist-loading';
  static const String showPlaylistRoute = 'show-playlist';
  static const String showAllPlaylistsRoute = 'show-all-playlists';
  static const String showAllAlbumsRoute = 'show-all-albums';
  static const String showAllGenericRoute = '/show-all-generic';
  static const String showPlaylistSongsRoute = '/show-playlist-songs';

  static const String searchResultRoute = 'search-result';
  static const String libraryUserPlaylistRoute = 'library-User-playlist';
  static const String savedArtistRoute = 'saved-artist-route';
  static const String favoritesSongsRoute = 'favorites-songs-route';
  static const String downloadedSongsRoute = 'downloaded-songs-route';

  static const String userInfoRoute = '/user-info';
  static const String userPlaylistSongsRoute = 'user-playlist-songs';
  static const String qualityRoute = '/quality';
  static const String offlineDownloadsRoute = '/offline_downloads';
  static const String podcastsRoute = '/podcasts';
  static const String audioBooksRoute = '/audio-books';
  static const String artistRoute = 'artist';
}

// Name class
class RouterName {
  // Shell routes
  static const String homeName = 'home';
  static const String recentName = 'recent';
  static const String searchName = 'search';
  static const String libraryName = 'library';
  static const String settingsName = 'settings';

  // Full screen routes
  static const String audioPlayerName = 'audioPlayer';
  // static const String playlistLoadingName = 'playlistLoading';
  static const String showPlaylistName = 'showPlaylist';
  static const String showAllPlaylistsName = 'showAllPlaylists';
  static const String showAllAlbumsName = 'showAllAlbums';
  static const String showAllGenericName = 'showAllGeneric';
  static const String showPlaylistSongsName = 'showPlaylistSongs';

  static const String searchResultName = 'searchResult';
  static const String libraryUserPlaylistName = 'libraryUserPlaylist';
  static const String savedArtistName = 'savedArtist';
  static const String favoritesSongsName = 'favoritesSongs';
  static const String downloadedSongsName = 'downloadedSongs';

  static const String userInfoName = 'userInfo';
  static const String userPlaylistSongsName = 'userPlaylistSongs';
  static const String qualityName = 'quality';
  static const String offlineDownloadsName = 'offlineDownloads';
  static const String podcastsName = 'podcasts';
  static const String audioBooksName = 'audioBooks';
  static const String artistName = 'artist';
}
