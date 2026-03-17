import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_music/core/route/go_router/go_router.dart';
import 'package:nex_music/bloc/user_playlist_bloc/bloc/user_playlist_bloc.dart';
import 'package:nex_music/model/user_playlist_model.dart';
import 'package:nex_music/core/wrapper/playlist_filter_wrapper.dart';
import '../widgets/user_playlist_tiles.dart';
import 'create_playlist_screen.dart';

class UserPlaylist extends StatefulWidget {
 
 
  final bool pickMode;
  final void Function(String playlistName)? onPlaylistPicked;

  const UserPlaylist({
    super.key,
    this.pickMode = false,
    this.onPlaylistPicked,
  });

  @override
  State<UserPlaylist> createState() => _UserPlaylistState();
}

class _UserPlaylistState extends State<UserPlaylist> {
  @override
  void initState() {
    context.read<UserPlaylistBloc>().add(GetUserPlaylistsEvent());
    super.initState();
  }

  void _showCreateDialog() {
    if (widget.pickMode) {
      showCupertinoModalPopup(
        context: context,
        builder: (dialogContext) => BlocProvider.value(
          value: context.read<UserPlaylistBloc>(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.85,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
              child: CreatePlaylistScreen(
                backLabel: 'Playlist',
                onCreate: ({
                  required String name,
                  required String description,
                  required int colorValue,
                  required String displayMode,
                  required bool isPublic,
                }) {
                  context.read<UserPlaylistBloc>().add(CreatePlaylistEvent(
                        playlistName: name,
                        description: description,
                        colorValue: colorValue,
                        displayMode: displayMode,
                        isPublic: isPublic,
                      ));
                },
              ),
            ),
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CreatePlaylistScreen(
            onCreate: ({
              required String name,
              required String description,
              required int colorValue,
              required String displayMode,
              required bool isPublic,
            }) {
              context.read<UserPlaylistBloc>().add(CreatePlaylistEvent(
                    playlistName: name,
                    description: description,
                    colorValue: colorValue,
                    displayMode: displayMode,
                    isPublic: isPublic,
                  ));
            },
          ),
        ),
      );
    }
  }

  void _confirmDelete(String playlistName) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Delete Playlist'),
        content: Text(
            'Are you sure you want to delete "$playlistName"? This action cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              context
                  .read<UserPlaylistBloc>()
                  .add(DeleteUserPlaylistEvent(playlistName: playlistName));
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(
      BuildContext context, int index, List<UserPlaylistModel> playlists) {
   
    if (index == 0) {
      return AddPlaylistTile(onTap: _showCreateDialog);
    }

   
    final userIndex = index - 1;
    if (userIndex < playlists.length) {
      final playlist = playlists[userIndex];
      final playlistName = playlist.name;
      final colorValue = playlist.colorValue;
      final displayMode = playlist.displayMode;
      final color = Color(colorValue);
      final thumbnails = playlist.thumbnails;

      void onTap() {
        if (widget.pickMode && widget.onPlaylistPicked != null) {
          widget.onPlaylistPicked!(playlistName);
          return;
        }

       
        String? thumbnail;
        if (displayMode == 'dynamic') {
          if (thumbnails.isNotEmpty) thumbnail = thumbnails.first;
        }

        final extra = {
          'name': playlistName,
          'colorValue': colorValue,
          if (thumbnail != null) 'thumbnail': thumbnail,
        };
        context.pushNamed(RouterName.userPlaylistSongsName, extra: extra);
      }

      if (displayMode == 'dynamic') {
        return UserPlaylistTile(
          playlistName: playlistName,
          color: color,
          displayMode: displayMode,
          thumbnails: thumbnails,
          onTap: onTap,
          onDelete: widget.pickMode ? null : () => _confirmDelete(playlistName),
        );
      }

      return UserPlaylistTile(
        playlistName: playlistName,
        color: color,
        displayMode: displayMode,
        onTap: onTap,
        onDelete: widget.pickMode ? null : () => _confirmDelete(playlistName),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () {
            if (widget.pickMode) {
              Navigator.pop(context);
            } else {
              context.pop();
            }
          },
          child: Row(
            children: [
              const SizedBox(width: 8),
              const Icon(Icons.arrow_back_ios, color: Colors.red, size: 20),
              Text(
                widget.pickMode ? 'Cancel' : 'Library',
                style: const TextStyle(color: Colors.red, fontSize: 17),
              ),
            ],
          ),
        ),
      ),
      body: BlocBuilder<UserPlaylistBloc, UserPlaylistState>(
        builder: (context, state) {
          if (state is UserPlaylistDataState) {
            return StreamBuilder<List<UserPlaylistModel>>(
              stream: state.data,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CupertinoActivityIndicator(
                      color: Colors.red,
                      radius: 15,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }

                final allPlaylists = snapshot.data ?? [];

                return PlaylistFilterWrapper(
                  title: 'Playlists',
                  playlists: allPlaylists,
                  builder: (context, filteredPlaylists) {
                    final gridItemCount = 1 + filteredPlaylists.length;

                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.82,
                      ),
                      itemCount: gridItemCount,
                      itemBuilder: (context, index) =>
                          _buildGridItem(context, index, filteredPlaylists),
                    );
                  },
                );
              },
            );
          }

          return const Center(
            child: CupertinoActivityIndicator(
              color: Colors.red,
              radius: 15,
            ),
          );
        },
      ),
    );
  }
}

// ─── DELETE SHEET ─────────────────────────────────────────────────────────────

class DeletePlaylistSheet extends StatelessWidget {
  final String playlistName;
  final VoidCallback onDelete;
  const DeletePlaylistSheet(
      {super.key, required this.playlistName, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  'Delete "$playlistName"?',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'This will permanently delete this playlist.\nThis action cannot be undone.',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white),
          TextButton(
            onPressed: onDelete,
            child: const Text(
              'Delete Playlist',
              style: TextStyle(
                  color: Colors.red, fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ),
          const Divider(height: 1, color: Colors.grey),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black, fontSize: 17),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
