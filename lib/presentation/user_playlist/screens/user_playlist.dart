import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/user_playlist_bloc/bloc/user_playlist_bloc.dart';
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/core/ui_component/animatedtext.dart';
import 'package:nex_music/presentation/user_playlist/screens/user_playlist_songs.dart';
import 'package:nex_music/presentation/user_playlist/widgets/create_playlistmodalsheet.dart';

class UserPlaylist extends StatefulWidget {
  const UserPlaylist({super.key});

  @override
  State<UserPlaylist> createState() => _UserPlaylistState();
}

class _UserPlaylistState extends State<UserPlaylist> {
  @override
  void initState() {
    context.read<UserPlaylistBloc>().add(GetUserPlaylistsEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.only(left: screenSize * 0.0131),
          child: const Text("Playlist"),
        ),
        actions: [
          IconButton(
              onPressed: () {
                // showCreatePlaylistDialog(context);
                createPlaylistBottomSheet(context, screenSize);
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: BlocBuilder<UserPlaylistBloc, UserPlaylistState>(
        buildWhen: (previous, current) => previous != current,
        builder: (context, state) {
          if (state is UserPlaylistDataState) {
            return Padding(
              padding: EdgeInsets.only(
                right: screenSize * 0.0131,
                left: screenSize * 0.0131,
                top: screenSize * 0.0131,
              ),
              child: StreamBuilder<List<String>>(
                  stream: state.data,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(snapshot.error.toString()),
                      );
                    } else if (snapshot.data!.isEmpty) {
                      return const Center(child: Text('No Playlist found!'));
                    }
                    final data = snapshot.data;
                    return ListView.builder(
                      itemCount: data!.length,
                      itemBuilder: (context, index) {
                        final playlistName = data[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: ListTile(
                            splashColor: Colors.transparent,
                            contentPadding: const EdgeInsets.all(12),
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                  UserPlaylistSongs.routeName,
                                  arguments: playlistName);
                            },
                            leading: CircleAvatar(
                              radius: 25,
                              backgroundColor: backgroundColor,
                              child: Icon(
                                Icons.library_music,
                                color: accentColor,
                                size: 25,
                              ),
                            ),
                            title: animatedText(
                                text: playlistName,
                                style:
                                    Theme.of(context).textTheme.titleMedium!),
                            trailing: IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text("Delete Playlist",
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium),
                                        content: Text(
                                          "Are you sure you want to delete this playlist? It will be deleted permanently.",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall,
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("Close",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                        color: textColor)),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              context
                                                  .read<UserPlaylistBloc>()
                                                  .add(DeleteUserPlaylistEvent(
                                                      playlistName:
                                                          playlistName));
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("Delete",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                        color: boldOrange)),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: Icon(
                                  Icons.delete,
                                  color: boldOrange,
                                )),
                          ),
                        );
                      },
                    );
                  }),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
