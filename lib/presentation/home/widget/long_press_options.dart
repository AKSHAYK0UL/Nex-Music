import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/favorites_bloc/bloc/favorites_bloc.dart';
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

Future<void> showLongPressOptions({
  required BuildContext context,
  required Songmodel songData,
  required double screenSize,
  required bool showDelete,
  required TabRouteENUM tabRouteENUM,
  String? playlistName,
}) async {
  showDialog(
    context: context,
    builder: (context) {
      return MediaQuery.sizeOf(context).width > 451
          ? Center(
              child: SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.2625,
                child: AlertDialog(
                  title: ListTile(
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
                      ),
                    ),
                    title: animatedText(
                      text: songData.songName,
                      style: Theme.of(context).textTheme.labelMedium!,
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
                      icon: Icon(
                        Icons.share,
                        color: textColor,
                      ),
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
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
                          style: Theme.of(context).textTheme.labelMedium!,
                        ),
                        style: TextButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          overlayColor: backgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: Icon(
                          Icons.play_arrow,
                          color: textColor,
                          size: screenSize * 0.0320,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          showAddToPlaylistDialog(context, songData);
                        },
                        label: Text(
                          "Add to Playlist",
                          style: Theme.of(context).textTheme.labelMedium!,
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
                          size: screenSize * 0.0320,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        label: animatedText(
                            text: "View Artist (${songData.artist.name})",
                            style: Theme.of(context).textTheme.labelMedium!),
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
                          size: screenSize * 0.0320,
                        ),
                      ),
                      if (showDelete)
                        TextButton.icon(
                          onPressed: () {
                            if (tabRouteENUM == TabRouteENUM.recent) {
                              context.read<SongDialogBloc>().add(
                                  RemoveFromRecentlyPlayedEvent(
                                      vId: songData.vId));
                            } else if (tabRouteENUM == TabRouteENUM.favorites) {
                              context.read<FavoritesBloc>().add(
                                  RemoveFromFavoritesEvent(vId: songData.vId));
                            } else if (tabRouteENUM == TabRouteENUM.playlist) {
                              print(" DeleteSongUserPlaylistEvent @@@");

                              context.read<UserPlaylistBloc>().add(
                                  DeleteSongUserPlaylistEvent(
                                      playlistName: playlistName ?? "",
                                      vId: songData.vId));
                            }
                            Navigator.of(context).pop();
                          },
                          label: animatedText(
                              text: "Remove Song",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium!
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
                            size: screenSize * 0.0320,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            )
          : AlertDialog(
              title: ListTile(
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
                  ),
                ),
                title: animatedText(
                  text: songData.songName,
                  style: Theme.of(context).textTheme.labelMedium!,
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
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
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
                      style: Theme.of(context).textTheme.labelMedium!,
                    ),
                    style: TextButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      overlayColor: backgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: Icon(
                      Icons.play_arrow,
                      color: textColor,
                      size: screenSize * 0.0320,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      showAddToPlaylistDialog(context, songData);
                    },
                    label: Text(
                      "Add to Playlist",
                      style: Theme.of(context).textTheme.labelMedium!,
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
                      size: screenSize * 0.0320,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    label: animatedText(
                        text: "View Artist (${songData.artist.name})",
                        style: Theme.of(context).textTheme.labelMedium!),
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
                      size: screenSize * 0.0320,
                    ),
                  ),
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
                        }
                        Navigator.of(context).pop();
                      },
                      label: animatedText(
                          text: "Remove Song",
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium!
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
                        size: screenSize * 0.0320,
                      ),
                    ),
                ],
              ),
            );
    },
  );
}
