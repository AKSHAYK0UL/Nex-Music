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
import 'package:nex_music/helper_function/routefunc/artistview_route.dart';
import 'package:nex_music/model/artistmodel.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/home/widget/bottom_sheet_button.dart';
import 'package:nex_music/presentation/user_playlist/widgets/add_to_playlist_bottom_sheet.dart';
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
                leading: SizedBox(
                  width: screenSize * 0.0755,
                  height: screenSize * 0.0733,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(screenSize * 0.0106),
                    child: cacheImage(
                      imageUrl: songData.thumbnail,
                      width: screenSize * 0.0755,
                      height: screenSize * 0.0733,
                      islocal: songData.isLocal,
                    ),
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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () async {
                        await Share.share(
                            "https://music.youtube.com/watch?v=${songData.vId}");
                        if (!context.mounted) return;
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.share,
                        size: screenSize * 0.035,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.close,
                        size: screenSize * 0.037,
                        color: boldOrange,
                      ),
                    )
                  ],
                ),
              ),

              Divider(
                color: accentColor,
                thickness: 1.5,
              ),
              //content

              bottomSheetButton(
                context: context,
                label: "Play Next",
                icon: Icons.play_circle_outlined,
                screenSize: screenSize,
                onPressed: () {
                  context
                      .read<SongstreamBloc>()
                      .add(AddToPlayNextEvent(songData: songData));
                  showSnackbar(context, "Added to Play Next");
                  Navigator.of(context).pop();
                },
              ),

              bottomSheetButton(
                context: context,
                label: "Add to Playlist",
                icon: Icons.playlist_add,
                screenSize: screenSize,
                onPressed: () {
                  final rootContext =
                      Navigator.of(context, rootNavigator: true).context;
                  Navigator.of(context).pop();
                  addToPlayListBottomSheet(rootContext, songData, screenSize);
                },
              ),

              bottomSheetButton(
                context: context,
                label: "View Artist (${songData.artist.name})",
                icon: Icons.person,
                screenSize: screenSize,
                onPressed: () {
                  Navigator.of(context).pop();
                  artistViewRoute(
                      context,
                      ArtistModel(
                          artist: songData.artist,
                          thumbnail: songData.thumbnail));
                },
              ),

              tabRouteENUM == TabRouteENUM.download
                  ? const SizedBox()
                  : BlocConsumer<DownloadBloc, DownloadState>(
                      listener: (context, state) {
                      if (state is DownloadErrorState) {
                        showSnackbar(context, state.errorMessage);
                      }
                      // if (state is DownloadPercantageStatusState) {
                      //   showSnackbar(context, "Downloading...");
                      // }
                    }, builder: (context, state) {
                      return bottomSheetButton(
                        context: context,
                        label: "Download",
                        icon: Icons.downloading_sharp,
                        screenSize: screenSize,
                        color: state is DownloadPercantageStatusState
                            ? Colors.grey.shade700
                            : textColor,
                        labelColor: state is DownloadPercantageStatusState
                            ? Colors.grey.shade700
                            : textColor,
                        onPressed: state is DownloadPercantageStatusState
                            ? null
                            : () {
                                context
                                    .read<DownloadBloc>()
                                    .add(DownloadSongEvent(songData: songData));

                                Navigator.of(context).pop();
                              },
                      );
                    }),
              if (showDelete)
                bottomSheetButton(
                  context: context,
                  label: "Remove Song",
                  icon: Icons.delete,
                  screenSize: screenSize,
                  color: boldOrange,
                  labelColor: boldOrange,
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
                ),
            ],
          ),
        ),
      );
    },
  );
}
