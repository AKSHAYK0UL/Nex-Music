import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/user_playlist_bloc/bloc/user_playlist_bloc.dart';

Future<void> showDialogBox(BuildContext context) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Enter Playlist name"),
          content: TextField(),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancle"),
            ),
            TextButton(
              onPressed: () {
                context
                    .read<UserPlaylistBloc>()
                    .add(CreatePlaylistEvent(playlistName: "xyz songs"));
              },
              child: Text("Create"),
            ),
          ],
        );
      });
}
