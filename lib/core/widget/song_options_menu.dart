import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/download_bloc/bloc/download_bloc.dart';
import 'package:nex_music/bloc/offline_songs_bloc/bloc/offline_songs_bloc.dart';
import 'package:nex_music/bloc/saved_artists_bloc/bloc/saved_artists_bloc.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/core/ui_component/snackbar.dart';
import 'package:nex_music/enum/tab_route.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_music/core/route/go_router/go_router.dart';
import 'package:nex_music/helper_function/check_song_downloaded/check_song_downloaded.dart';
import 'package:nex_music/model/artistmodel.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/user_playlist/widgets/add_to_playlist_bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';

enum SongMenuType {
  recent,
  audioPlayer,
  playlist,
  favorites,
  search,
}

class SongOptionsMenu extends StatelessWidget {
  final Songmodel songData;
  final double screenSize;
  final TabRouteENUM tabRouteENUM;
  final SongMenuType menuType;
  final String? playlistName;
  final VoidCallback? onTimerTap;
  final VoidCallback? onDeleteFromRecent;
  final String? customDeleteText;
  final VoidCallback? onCustomDelete;
  final bool showDelete;

  const SongOptionsMenu({
    super.key,
    required this.songData,
    required this.screenSize,
    required this.tabRouteENUM,
    required this.menuType,
    this.playlistName,
    this.onTimerTap,
    this.onDeleteFromRecent,
    this.customDeleteText,
    this.onCustomDelete,
    this.showDelete = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget content = Container(
      width: 250,
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.2),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 50,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildMenuItems(context),
      ),
    );

    if (!isDark) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: content,
        ),
      );
    }

    return content;
  }

  List<Widget> _buildMenuItems(BuildContext context) {
    List<Widget> items = [];

    switch (menuType) {
      case SongMenuType.recent:
        // Delete option - only show if showDelete is true
        if (showDelete) {
          if (customDeleteText != null && onCustomDelete != null) {
            items.add(_buildMenuItem(
              customDeleteText!,
              CupertinoIcons.trash,
              textColor: const Color(0xFFFF3B30),
              iconColor: const Color(0xFFFF3B30),
              onTap: () {
                Navigator.pop(context);
                onCustomDelete!();
              },
            ));
          } else {
            // Delete from Recent
            items.add(_buildMenuItem(
              "Remove from Recent",
              CupertinoIcons.trash,
              textColor: const Color(0xFFFF3B30),
              iconColor: const Color(0xFFFF3B30),
              onTap: () {
                Navigator.pop(context);
                if (onDeleteFromRecent != null) {
                  onDeleteFromRecent!();
                } else {
                  showSnackbar(context,
                      "Delete from recent functionality not implemented");
                }
              },
            ));
          }
          items.add(_buildDivider(context));
        }

        // Add to Playlist
        items.add(_buildMenuItem(
          "Add to a Playlist...",
          CupertinoIcons.text_badge_plus,
          textColor:
              Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
          iconColor: Theme.of(context).iconTheme.color ?? Colors.black87,
          onTap: () {
            Navigator.pop(context);
            addToPlayListBottomSheet(context, songData, screenSize);
          },
        ));
        items.add(_buildDivider(context));

        // Share
        items.add(_buildMenuItem(
          "Share Song...",
          CupertinoIcons.share,
          textColor:
              Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
          iconColor: Theme.of(context).iconTheme.color ?? Colors.black87,
          onTap: () async {
            Navigator.pop(context);
            await Share.share(
              "https://music.youtube.com/watch?v=${songData.vId}",
            );
          },
        ));
        items.add(_buildDivider(context));

        // Download
        if (!(tabRouteENUM == TabRouteENUM.download && songData.isLocal)) {
          items.add(_buildDownloadMenuItem(context));
          items.add(_buildDivider(context));
        }

        // View Artist
        items.add(_buildMenuItem(
          "View Artist",
          CupertinoIcons.person_crop_circle,
          textColor:
              Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
          iconColor: Theme.of(context).iconTheme.color ?? Colors.black87,
          onTap: () {
            Navigator.pop(context); // Pop the bottom sheet

            // If in audio player, pop it first to show bottom nav
            if (menuType == SongMenuType.audioPlayer) {
              context.pop();
            }

            context.pushNamed(
              RouterName.artistName,
              extra: ArtistModel(
                artist: songData.artist,
                thumbnail: songData.thumbnail,
              ),
            );
          },
        ));
        items.add(_buildDivider(context));

        // Play Next
        items.add(_buildMenuItem(
          "Play Next",
          CupertinoIcons.play_arrow,
          textColor:
              Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
          iconColor: Theme.of(context).iconTheme.color ?? Colors.black87,
          onTap: () {
            Navigator.pop(context);
            context.read<SongstreamBloc>().add(
                  AddToPlayNextEvent(songData: songData),
                );
            showSnackbar(context, "Added to play queue");
          },
          isLast: true,
        ));
        break;

      case SongMenuType.audioPlayer:
        // // Start Radio
        // items.add(_buildMenuItem(
        //   "Start Radio",
        //   CupertinoIcons.antenna_radiowaves_left_right,
        //   textColor: Colors.black,
        //   iconColor: Colors.black87,
        //   onTap: () {
        //     Navigator.pop(context);
        //     context.read<SongstreamBloc>().add(
        //           StartRadioEvent(videoId: songData.vId),
        //         );
        //     showSnackbar(context, "Starting radio based on this song");
        //   },
        // ));
        // items.add(_buildDivider());

        // Delete from Library
        // items.add(_buildMenuItem(
        //   "Delete from Library",
        //   CupertinoIcons.trash,
        //   textColor: const Color(0xFFFF3B30),
        //   iconColor: const Color(0xFFFF3B30),
        //   onTap: () {
        //     Navigator.pop(context);
        //     showSnackbar(context, "Delete functionality not implemented");
        //   },
        // ));
        // items.add(_buildDivider());

        // Add to Playlist
        items.add(_buildMenuItem(
          "Add to a Playlist...",
          CupertinoIcons.text_badge_plus,
          textColor:
              Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
          iconColor: Theme.of(context).iconTheme.color ?? Colors.black87,
          onTap: () {
            Navigator.pop(context);
            addToPlayListBottomSheet(context, songData, screenSize);
          },
        ));
        items.add(_buildDivider(context));

        // Save Artist
        items.add(BlocBuilder<SavedArtistsBloc, SavedArtistsState>(
          builder: (context, state) {
            bool isSaved = false;
            final artistId = songData.artist.artistId;
            if (artistId != null) {
              if (state is IsArtistSavedState && state.artistId == artistId) {
                isSaved = state.isSaved;
              } else {
                // Check if artist is saved when menu opens
                context.read<SavedArtistsBloc>().add(
                      IsArtistSavedEvent(artistId: artistId),
                    );
              }
            }
            return _buildMenuItem(
              isSaved ? "Remove Artist" : "Save Artist",
              isSaved
                  ? CupertinoIcons.person_crop_circle_badge_minus
                  : CupertinoIcons.person_crop_circle_badge_plus,
              textColor: isSaved
                  ? const Color(0xFFFF3B30)
                  : (Theme.of(context).textTheme.bodyMedium?.color ??
                      Colors.black),
              iconColor: isSaved
                  ? const Color(0xFFFF3B30)
                  : (Theme.of(context).iconTheme.color ?? Colors.black87),
              onTap: artistId != null
                  ? () {
                      Navigator.pop(context);
                      if (isSaved) {
                        context.read<SavedArtistsBloc>().add(
                              RemoveFromSavedArtistsEvent(artistId: artistId),
                            );
                        showSnackbar(context, "Artist removed from saved");
                      } else {
                        context.read<SavedArtistsBloc>().add(
                              AddToSavedArtistsEvent(
                                  artist: ArtistModel(
                                artist: songData.artist,
                                thumbnail: songData.thumbnail,
                              )),
                            );
                        showSnackbar(context, "Artist saved");
                      }
                    }
                  : null,
            );
          },
        ));
        items.add(_buildDivider(context));

        // Share Song
        items.add(_buildMenuItem(
          "Share Song...",
          CupertinoIcons.share,
          textColor:
              Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
          iconColor: Theme.of(context).iconTheme.color ?? Colors.black87,
          onTap: () async {
            Navigator.pop(context);
            await Share.share(
              "https://music.youtube.com/watch?v=${songData.vId}",
            );
          },
        ));
        items.add(_buildDivider(context));

        // Download
        items.add(_buildDownloadMenuItem(context));
        items.add(_buildDivider(context));

        // Set Timer
        items.add(_buildMenuItem(
          "Set Timer",
          CupertinoIcons.timer,
          textColor:
              Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
          iconColor: Theme.of(context).iconTheme.color ?? Colors.black87,
          onTap: onTimerTap != null
              ? () {
                  onTimerTap!();
                }
              : null,
          isLast: true,
        ));
        items.add(_buildDivider(context));

        // Start Radio
        items.add(_buildMenuItem(
          "Start Radio",
          Icons.radio,
          textColor:
              Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
          iconColor: Theme.of(context).iconTheme.color ?? Colors.black87,
          onTap: () {
            Navigator.pop(context);
            context.read<SongstreamBloc>().add(
                  StartRadioEvent(videoId: songData.vId),
                );
            showSnackbar(context, "Radio songs added to queue");
          },
        ));

        break;

      default:
        // Default menu items for other types
        items.add(_buildMenuItem(
          "Add to a Playlist...",
          CupertinoIcons.text_badge_plus,
          textColor:
              Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
          iconColor: Theme.of(context).iconTheme.color ?? Colors.black87,
          onTap: () {
            Navigator.pop(context);
            addToPlayListBottomSheet(context, songData, screenSize);
          },
        ));
        items.add(_buildDivider(context));

        items.add(_buildMenuItem(
          "Share Song...",
          CupertinoIcons.share,
          textColor:
              Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
          iconColor: Theme.of(context).iconTheme.color ?? Colors.black87,
          onTap: () async {
            Navigator.pop(context);
            await Share.share(
              "https://music.youtube.com/watch?v=${songData.vId}",
            );
          },
        ));
        items.add(_buildDivider(context));

        items.add(_buildDownloadMenuItem(context, isLast: true));
        break;
    }

    return items;
  }

  Widget _buildDownloadMenuItem(BuildContext context, {bool isLast = false}) {
    return FutureBuilder<bool>(
      future: isSongDownloaded(songData),
      builder: (context, snapshot) {
        // Check actual file existence, not just songData.isLocal
        final isDownloaded = snapshot.data ?? false;

        return BlocBuilder<DownloadBloc, DownloadState>(
          builder: (context, state) {
            final isDownloading = state is DownloadPercantageStatusState;

            if (isDownloading) {
              return StreamBuilder<double>(
                stream: state.percentageStream,
                builder: (context, snapshot) {
                  final progress = snapshot.data ?? 0.0;
                  return _buildMenuItem(
                    "Downloading... ${progress.toInt()}%",
                    CupertinoIcons.cloud_download,
                    textColor: Colors.grey,
                    iconColor: Colors.grey,
                    onTap: null,
                    isLast: isLast,
                  );
                },
              );
            } else if (isDownloaded) {
              if (tabRouteENUM == TabRouteENUM.download) {
                return const SizedBox.shrink();
              }

              return _buildMenuItem(
                "Remove from Downloads",
                CupertinoIcons.trash,
                textColor: const Color(0xFFFF3B30),
                iconColor: const Color(0xFFFF3B30),
                onTap: () {
                  Navigator.pop(context);
                  context.read<OfflineSongsBloc>().add(
                        DeleteDownloadedSongEvent(songData: songData),
                      );
                  showSnackbar(context, "Removed from downloads");
                },
                isLast: isLast,
              );
            } else {
              return _buildMenuItem(
                "Download",
                CupertinoIcons.cloud_download,
                textColor: Theme.of(context).textTheme.bodyMedium?.color ??
                    Colors.black,
                iconColor: Theme.of(context).iconTheme.color ?? Colors.black87,
                onTap: () {
                  Navigator.pop(context);
                  context.read<DownloadBloc>().add(
                        DownloadSongEvent(songData: songData),
                      );
                },
                isLast: isLast,
              );
            }
          },
        );
      },
    );
  }

  Widget _buildMenuItem(
    String title,
    IconData icon, {
    required Color textColor,
    required Color iconColor,
    bool isLast = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: textColor,
                letterSpacing: -0.3,
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.none,
              ),
            ),
            Icon(icon, color: iconColor, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Container(
        height: 0.5,
        margin: const EdgeInsets.only(left: 16),
        color: Theme.of(context).dividerColor,
      ),
    );
  }
}
