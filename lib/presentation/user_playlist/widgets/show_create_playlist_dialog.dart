import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/user_playlist_bloc/bloc/user_playlist_bloc.dart';

import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/core/ui_component/snackbar.dart';

Future<void> showCreatePlaylistDialog(BuildContext context) {
  TextEditingController playlistNameController = TextEditingController();

  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          "Enter Playlist Name",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        content: TextField(
          controller: playlistNameController,
          decoration: InputDecoration(
            hintText: "My Playlist",
            hintStyle: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey),
          ),
          autofocus: true,
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
                showSnackbar(context, "Playlist created successfully");
                Navigator.of(context).pop();
              } else {
                //n
                showSnackbar(context, "Playlist name cannot be empty");
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
