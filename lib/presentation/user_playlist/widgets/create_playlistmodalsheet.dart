import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/user_playlist_bloc/bloc/user_playlist_bloc.dart';
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/core/ui_component/snackbar.dart';

Future<void> createPlaylistBottomSheet(
    BuildContext context, double screenSize) async {
  TextEditingController playlistNameController = TextEditingController();

  return showModalBottomSheet(
      context: context,
      backgroundColor: secondaryColor,
      builder: (context) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 150),
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: screenSize * 0.015, vertical: screenSize * 0.012),
              width: double.infinity,
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(screenSize * 0.015),
                    topRight: Radius.circular(screenSize * 0.015)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Playlist Name",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextField(
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
                  SizedBox(
                    height: screenSize * 0.0250,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Close",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          final playlistName =
                              playlistNameController.text.trim();

                          if (playlistName.isNotEmpty) {
                            context.read<UserPlaylistBloc>().add(
                                  CreatePlaylistEvent(
                                      playlistName: playlistName),
                                );
                            showSnackbar(
                                context, "Playlist created successfully");
                            Navigator.of(context).pop();
                          } else {
                            //n
                            showSnackbar(
                                context, "Playlist name cannot be empty");
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
                  ),
                ],
              ),
            ),
          ),
        );
      });
}
