import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/download_bloc/bloc/download_bloc.dart';
import 'package:nex_music/bloc/favorites_bloc/bloc/favorites_bloc.dart';
import 'package:nex_music/bloc/offline_songs_bloc/bloc/offline_songs_bloc.dart';
import 'package:nex_music/bloc/song_dialog_bloc/bloc/song_dialog_bloc.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/bloc/user_playlist_bloc/bloc/user_playlist_bloc.dart';
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/core/ui_component/animatedtext.dart';
import 'package:nex_music/core/ui_component/cacheimage.dart';
import 'package:nex_music/core/ui_component/snackbar.dart';
import 'package:nex_music/enum/tab_route.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/user_playlist/widgets/add_to_playlist_dialog.dart';
import 'package:share_plus/share_plus.dart';

Future<void> showBottomOptionSheet({
  required BuildContext context,
  required Songmodel songData,
  required double screenSize,
  required bool showDelete,
  required TabRouteENUM tabRouteENUM,
  String? playlistName,
}) async {
  return showModalBottomSheet(
    backgroundColor: Colors.transparent,
    context: context,
    builder: (context) {
      return Container(
        padding: EdgeInsets.symmetric(
            horizontal: screenSize * 0.015, vertical: screenSize * 0.012),
        width: double.infinity,
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(screenSize * 0.015),
              topRight: Radius.circular(screenSize * 0.015)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //title

              ListTile(
                tileColor: backgroundColor,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: screenSize * 0.0050,
                    vertical: screenSize * 0.00005),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(screenSize * 0.0106),
                  child: cacheImage(
                    imageUrl: songData.thumbnail,
                    width: screenSize * 0.0755,
                    height: screenSize * 0.0733,
                    islocal: songData.isLocal,
                  ),
                ),
                title: animatedText(
                  text: songData.songName,
                  style: Theme.of(context).textTheme.displayMedium!,
                ),
                subtitle: animatedText(
                  text: songData.artist.name,
                  style: Theme.of(context).textTheme.bodySmall!,
                ),
                trailing: IconButton(
                  onPressed: () async {
                    await Share.share(
                        "https://music.youtube.com/watch?v=${songData.vId}");
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.share),
                ),
              ),

              Divider(
                color: accentColor,
                thickness: 1.5,
              ),
              //content
              TextButton.icon(
                onPressed: () {
                  context
                      .read<SongstreamBloc>()
                      .add(AddToPlayNextEvent(songData: songData));
                  showSnackbar(context, "Added to Play Next");
                  Navigator.of(context).pop();
                },
                label: Text(
                  "Play Next",
                  style: Theme.of(context).textTheme.displayMedium!,
                ),
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  overlayColor: backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: Icon(
                  Icons.play_circle_outlined,
                  color: textColor,
                  size: screenSize * 0.0360,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  //using the root navigator's context (which persists after popping your current route).
                  final rootContext =
                      Navigator.of(context, rootNavigator: true).context;

                  Navigator.of(context).pop();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    showAddToPlaylistDialog(rootContext, songData);
                  });
                },
                label: Text(
                  "Add to Playlist",
                  style: Theme.of(context).textTheme.displayMedium!,
                ),
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  overlayColor: backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: Icon(
                  Icons.playlist_add,
                  color: textColor,
                  size: screenSize * 0.0360,
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                label: animatedText(
                    text: "View Artist (${songData.artist.name})",
                    style: Theme.of(context).textTheme.displayMedium!),
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  overlayColor: backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: Icon(
                  Icons.person,
                  color: textColor,
                  size: screenSize * 0.0360,
                ),
              ),
              tabRouteENUM == TabRouteENUM.download
                  ? const SizedBox()
                  : BlocConsumer<DownloadBloc, DownloadState>(
                      listener: (context, state) {
                      if (state is DownloadErrorState) {
                        showSnackbar(context, state.errorMessage);
                      }
                      if (state is DownloadPercantageStatusState) {
                        showSnackbar(context, "Downloading...");
                      }
                    }, builder: (context, state) {
                      return TextButton.icon(
                        onPressed: state is DownloadPercantageStatusState
                            ? null
                            : () {
                                context
                                    .read<DownloadBloc>()
                                    .add(DownloadSongEvent(songData: songData));

                                Navigator.of(context).pop();
                              },
                        label: Text(
                          "Download",
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(
                                  color: state is DownloadPercantageStatusState
                                      ? Colors.grey.shade700
                                      : textColor),
                        ),
                        style: TextButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          overlayColor: backgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: Icon(
                          Icons.downloading_sharp,
                          color: state is DownloadPercantageStatusState
                              ? Colors.grey.shade700
                              : textColor,
                          size: screenSize * 0.0360,
                        ),
                      );
                    }),
              if (showDelete)
                TextButton.icon(
                  onPressed: () {
                    if (tabRouteENUM == TabRouteENUM.recent) {
                      context.read<SongDialogBloc>().add(
                          RemoveFromRecentlyPlayedEvent(vId: songData.vId));
                    } else if (tabRouteENUM == TabRouteENUM.favorites) {
                      context
                          .read<FavoritesBloc>()
                          .add(RemoveFromFavoritesEvent(vId: songData.vId));
                    } else if (tabRouteENUM == TabRouteENUM.playlist) {
                      context.read<UserPlaylistBloc>().add(
                          DeleteSongUserPlaylistEvent(
                              playlistName: playlistName ?? "",
                              vId: songData.vId));
                    } else if (tabRouteENUM == TabRouteENUM.download) {
                      context.read<OfflineSongsBloc>().add(
                            DeleteDownloadedSongEvent(
                              songData: songData,
                            ),
                          );
                    }
                    Navigator.of(context).pop();
                  },
                  label: animatedText(
                      text: "Remove Song",
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium!
                          .copyWith(color: boldOrange)),
                  style: TextButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    overlayColor: backgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Icon(
                    Icons.delete,
                    color: boldOrange,
                    size: screenSize * 0.0360,
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}
