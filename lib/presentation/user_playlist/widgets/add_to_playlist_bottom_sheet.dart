import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/user_playlist_bloc/bloc/user_playlist_bloc.dart';
import 'package:nex_music/core/ui_component/snackbar.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/user_playlist/screens/user_playlist.dart';
import 'package:nex_music/repository/db_repository/db_repository.dart';



Future<void> addToPlayListBottomSheet(
    BuildContext context, Songmodel currentSong, double screenSize) async {
 
  context.read<UserPlaylistBloc>().add(GetUserPlaylistsEvent());

  final userPlaylistBloc = context.read<UserPlaylistBloc>();
  final dbRepository = context.read<DbRepository>();

  await showCupertinoModalPopup(
    context: context,
    builder: (dialogContext) {
      return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: userPlaylistBloc),
        ],
        child: RepositoryProvider.value(
          value: dbRepository,
          child: SizedBox(
            height: MediaQuery.of(dialogContext).size.height * 0.85,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: UserPlaylist(
                pickMode: true,
                onPlaylistPicked: (playlistName) {
                  userPlaylistBloc.add(
                    AddSongToUserPlaylistEvent(
                      playlistName: playlistName,
                      songData: currentSong,
                    ),
                  );
                  Navigator.pop(dialogContext);
                  showSnackbar(context, "Added to $playlistName");
                },
              ),
            ),
          ),
        ),
      );
    },
  );
}
