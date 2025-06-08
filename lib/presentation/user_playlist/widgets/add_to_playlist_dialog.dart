import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/user_playlist_bloc/bloc/user_playlist_bloc.dart';
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/core/ui_component/animatedtext.dart';
import 'package:nex_music/core/ui_component/snackbar.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/user_playlist/widgets/show_create_playlist_dialog.dart';

void showAddToPlaylistDialog(BuildContext context, Songmodel currentSong) {
  context.read<UserPlaylistBloc>().add(GetUserPlaylistsEvent());

  showDialog(
    context: context,
    builder: (dialogContext) {
      return BlocProvider.value(
        value: BlocProvider.of<UserPlaylistBloc>(context),
        child: AlertDialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          titlePadding: const EdgeInsets.only(left: 24, top: 24, right: 8),
          contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          actionsPadding: const EdgeInsets.only(bottom: 12, right: 12),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Select Playlist',
                  style: Theme.of(context).textTheme.titleLarge),
              IconButton(
                onPressed: () {
                  showCreatePlaylistDialog(context);
                },
                icon: Icon(Icons.add, color: textColor),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: BlocBuilder<UserPlaylistBloc, UserPlaylistState>(
              buildWhen: (previous, current) => previous != current,
              builder: (context, state) {
                if (state is UserPlaylistLoadingState ||
                    state is UserPlaylistInitial) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is UserPlaylistDataState) {
                  return StreamBuilder<List<String>>(
                    stream: state.data,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No Playlist Found'));
                      }

                      final playlists = snapshot.data!;
                      return SizedBox(
                        height: 287,
                        child: ListView.builder(
                          itemCount: playlists.length,
                          itemBuilder: (context, index) {
                            final playlistName = playlists[index];
                            return GestureDetector(
                              onTap: () {
                                context.read<UserPlaylistBloc>().add(
                                      AddSongToUserPlaylistEvent(
                                        playlistName: playlistName,
                                        songData: currentSong,
                                      ),
                                    );
                                showSnackbar(context, "Added to $playlistName");
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: secondaryColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  spacing: 15,
                                  children: [
                                    CircleAvatar(
                                      radius: 25,
                                      backgroundColor: backgroundColor,
                                      child: Icon(
                                        Icons.library_music,
                                        color: accentColor,
                                        size: 25,
                                      ),
                                    ),
                                    animatedText(
                                      text: playlistName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!,
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                }

                return const SizedBox();
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Close ",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      );
    },
  );
}
