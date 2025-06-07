import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/user_playlist_bloc/bloc/user_playlist_bloc.dart';
import 'package:nex_music/core/theme/hexcolor.dart';

Future<void> showDialogBox(BuildContext context) {
  TextEditingController playlistNameController = TextEditingController();

  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Enter Playlist Name"),
        content: TextField(
          controller: playlistNameController,
          decoration: const InputDecoration(hintText: "My Playlist"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              "Close",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: boldOrange),
            ),
          ),
          TextButton(
            onPressed: () {
              final playlistName = playlistNameController.text.trim();

              if (playlistName.isNotEmpty) {
                context.read<UserPlaylistBloc>().add(
                      CreatePlaylistEvent(playlistName: playlistName),
                    );
                Navigator.of(context).pop;
              } else {
                //n
              }
            },
            child: Text(
              "Done",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: accentColor),
            ),
          ),
        ],
      );
    },
  );
}
