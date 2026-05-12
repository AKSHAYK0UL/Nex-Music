import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/favorites_bloc/bloc/favorites_bloc.dart';
import 'package:nex_music/bloc/offline_songs_bloc/bloc/offline_songs_bloc.dart';
import 'package:nex_music/bloc/song_dialog_bloc/bloc/song_dialog_bloc.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/core/services/hive_singleton.dart';
import 'package:nex_music/core/ui_component/animatedtext.dart';
import 'package:nex_music/core/ui_component/cacheimage.dart';
import 'package:nex_music/core/ui_component/snackbar.dart';
import 'package:nex_music/core/widget/song_options_menu.dart';
import 'package:nex_music/enum/quality.dart';
import 'package:nex_music/enum/song_miniplayer_route.dart';
import 'package:nex_music/enum/tab_route.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_music/bloc/user_playlist_bloc/bloc/user_playlist_bloc.dart';
import 'package:nex_music/core/route/go_router/go_router.dart';

class RecentSongTile extends StatefulWidget {
  final Songmodel songData;
  final int songIndex;
  final TabRouteENUM tabRouteENUM;
  final List<Songmodel>? playlistSongs;
  final bool showDelete;
  final bool isCurrent;
  final String? playlistName;

  const RecentSongTile({
    super.key,
    required this.songData,
    required this.songIndex,
    required this.tabRouteENUM,
    this.playlistSongs,
    this.showDelete = true,
    this.isCurrent = false,
    this.playlistName,
  });

  @override
  State<RecentSongTile> createState() => _RecentSongTileState();
}

class _RecentSongTileState extends State<RecentSongTile> {
  ThumbnailQuality quality = ThumbnailQuality.low;
  final HiveDataBaseSingleton _dataBaseSingleton =
      HiveDataBaseSingleton.instance;
  final GlobalKey _menuButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final data = _dataBaseSingleton.getData;
      setState(() {
        quality = data.thumbnailQuality;
      });
    });
  }

  Widget _buildSongOptionsMenu(BuildContext context, double screenHeight) {
    // Determine menu type and delete handler based on tabRouteENUM
    switch (widget.tabRouteENUM) {
      case TabRouteENUM.recent:
        return SongOptionsMenu(
          songData: widget.songData,
          screenSize: screenHeight,
          tabRouteENUM: widget.tabRouteENUM,
          menuType: SongMenuType.recent,
          showDelete: widget.showDelete,
          onDeleteFromRecent: widget.showDelete
              ? () {
                  context.read<SongDialogBloc>().add(
                      RemoveFromRecentlyPlayedEvent(vId: widget.songData.vId));
                  showSnackbar(context, "Removed from recent songs");
                }
              : null,
        );
      case TabRouteENUM.download:
        return SongOptionsMenu(
          songData: widget.songData,
          screenSize: screenHeight,
          tabRouteENUM: widget.tabRouteENUM,
          menuType: SongMenuType.recent,
          showDelete: widget.showDelete,
          customDeleteText: widget.showDelete ? "Remove from Downloads" : null,
          onCustomDelete: widget.showDelete
              ? () {
                  context.read<OfflineSongsBloc>().add(
                        DeleteDownloadedSongEvent(songData: widget.songData),
                      );
                  showSnackbar(context, "Removed from downloads");
                }
              : null,
        );
      case TabRouteENUM.favorites:
        return SongOptionsMenu(
          songData: widget.songData,
          screenSize: screenHeight,
          tabRouteENUM: widget.tabRouteENUM,
          menuType: SongMenuType.recent,
          showDelete: widget.showDelete,
          customDeleteText: widget.showDelete ? "Remove from Favorites" : null,
          onCustomDelete: widget.showDelete
              ? () {
                  context.read<FavoritesBloc>().add(
                        RemoveFromFavoritesEvent(vId: widget.songData.vId),
                      );
                  showSnackbar(context, "Removed from favorites");
                }
              : null,
        );
      case TabRouteENUM.playlist:
        return SongOptionsMenu(
          songData: widget.songData,
          screenSize: screenHeight,
          tabRouteENUM: widget.tabRouteENUM,
          menuType: SongMenuType.recent,
          showDelete: widget.showDelete,
          playlistName: widget.playlistName,
          customDeleteText: widget.showDelete ? "Remove from Playlist" : null,
          onCustomDelete: widget.showDelete
              ? () {
                  context.read<UserPlaylistBloc>().add(
                        DeleteSongUserPlaylistEvent(
                          playlistName: widget.playlistName ?? "",
                          vId: widget.songData.vId,
                        ),
                      );
                  showSnackbar(context, "Removed from playlist");
                }
              : null,
        );
      default:
        return SongOptionsMenu(
          songData: widget.songData,
          screenSize: screenHeight,
          tabRouteENUM: widget.tabRouteENUM,
          menuType: SongMenuType.recent,
          showDelete: widget.showDelete,
        );
    }
  }

  void _showOptionsMenu(BuildContext context) {
    final RenderBox? renderBox =
        _menuButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size buttonSize = renderBox.size;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    final bool showAbove = offset.dy > screenHeight / 2;

    const double menuWidth = 250.0;
    const double padding = 16.0;
    const double gap = 4.0;

    double leftPosition = offset.dx + buttonSize.width - menuWidth;

    if (leftPosition + menuWidth > screenWidth - padding) {
      leftPosition = screenWidth - menuWidth - padding;
    } else if (leftPosition < padding) {
      leftPosition = padding;
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.transparent,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Stack(
          children: [
            // Dismiss on tap outside
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(color: Colors.transparent),
              ),
            ),
            Positioned(
              left: leftPosition,
              width: menuWidth,
              top: showAbove ? null : offset.dy + buttonSize.height + gap,
              bottom: showAbove ? screenHeight - offset.dy + gap : null,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: showAbove
                      ? offset.dy - padding - gap
                      : screenHeight -
                          (offset.dy + buttonSize.height) -
                          padding -
                          gap,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: SingleChildScrollView(
                    child: _buildSongOptionsMenu(context, screenHeight),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        if (widget.tabRouteENUM == TabRouteENUM.upNext) {
          context.pop();
        }
        if (widget.tabRouteENUM == TabRouteENUM.playlist ||
            widget.tabRouteENUM == TabRouteENUM.download) {
          context.read<SongstreamBloc>().add(
                PlaySongFromPlaylistEvent(
                  songData: widget.songData,
                  songIndex: widget.songIndex,
                  playlistSongs: widget.playlistSongs!,
                ),
              );
        } else {
          context.read<SongstreamBloc>().add(
                PlayIndividualSongEvent(
                  songData: widget.songData,
                  songIndex: widget.songIndex,
                ),
              );
        }

        if (widget.tabRouteENUM != TabRouteENUM.upNext) {
          context.push(
            RouterPath.audioPlayerRoute,
            extra: {
              "songindex": widget.songIndex,
              'songdata': widget.songData,
              'route': SongMiniPlayerRoute.songRoute,
              'isplaylist': widget.tabRouteENUM == TabRouteENUM.playlist ||
                  widget.tabRouteENUM == TabRouteENUM.download,
              "quality": quality,
            },
          );
        }
      },
      child: Container(
        height: 85,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: widget.isCurrent
              ? theme.colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.1)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            // Album Art
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: cacheImage(
                  imageUrl: widget.songData.thumbnail,
                  width: 70,
                  height: 70,
                  islocal: widget.songData.isLocal,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Text Content
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.onSurface.withValues(alpha: isDark ? 0.18 : 0.12),
                      width: 1.0,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          animatedText(
                            text: widget.songData.songName,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          animatedText(
                            text: widget.songData.artist.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      key: _menuButtonKey,
                      onPressed: () => _showOptionsMenu(context),
                      icon: CircleAvatar(
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                        radius: 12,
                        child: Icon(
                          Icons.more_vert,
                          color: theme.colorScheme.primary,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
