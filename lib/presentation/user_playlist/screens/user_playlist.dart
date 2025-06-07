import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/user_playlist_bloc/bloc/user_playlist_bloc.dart';
import 'package:nex_music/presentation/user_playlist/screens/user_playlist_songs.dart';
import 'package:nex_music/presentation/user_playlist/widgets/show_dialog.dart';

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
          child: Text("Playlist"),
        ),
        actions: [
          IconButton(
              onPressed: () {
                showDialogBox(context);
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: BlocBuilder<UserPlaylistBloc, UserPlaylistState>(
        buildWhen: (previous, current) => previous != current,
        builder: (context, state) {
          if (state is UserPlaylistDataState) {
            print("UserPlaylistDataState @@@");

            return StreamBuilder<List<String>>(
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
                    return const Center(child: Text('No Playlist'));
                  }
                  final data = snapshot.data;
                  return ListView.builder(
                      itemCount: data!.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                                UserPlaylistSongs.routeName,
                                arguments: data[index]);
                          },
                          title: Text(
                            data[index],
                          ),
                        );
                      });
                });
          }
          return const SizedBox();
        },
      ),
    );
  }
}
