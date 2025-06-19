import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/user_playlist_bloc/bloc/user_playlist_bloc.dart';
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/core/ui_component/animatedtext.dart';
import 'package:nex_music/core/ui_component/snackbar.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/user_playlist/widgets/create_playlistmodalsheet.dart';

Future<void> addToPlayListBottomSheet(
    BuildContext context, Songmodel currentSong, double screenSize) async {
  context.read<UserPlaylistBloc>().add(GetUserPlaylistsEvent());
  return showModalBottomSheet(
    context: context,
    backgroundColor: secondaryColor,
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
        child: BlocProvider.value(
          value: BlocProvider.of<UserPlaylistBloc>(context),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(' Select Playlist',
                        style: Theme.of(context).textTheme.titleLarge),
                    IconButton(
                      onPressed: () {
                        createPlaylistBottomSheet(context, screenSize);
                      },
                      icon: Icon(Icons.add, color: textColor),
                    ),
                  ],
                ),
                Divider(
                  color: accentColor,
                  thickness: 1.5,
                ),
                SizedBox(
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
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            }
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Center(
                                  child: Text('No Playlist Found'));
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
                                      showSnackbar(
                                          context, "Added to $playlistName");
                                      Navigator.of(context).pop();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      decoration: BoxDecoration(
                                        color: backgroundColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        spacing: 15,
                                        children: [
                                          CircleAvatar(
                                            radius: 25,
                                            backgroundColor: secondaryColor,
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
              ],
            ),
          ),
        ),
      );
    },
  );
}
