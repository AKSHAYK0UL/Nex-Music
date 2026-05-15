import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_music/bloc/saved_playlists_bloc/bloc/saved_playlists_bloc.dart';
import 'package:nex_music/core/route/go_router/go_router.dart';
import 'package:nex_music/bloc/user_playlist_bloc/bloc/user_playlist_bloc.dart';
import 'package:nex_music/core/ui_component/cacheimage.dart';
import 'package:nex_music/model/playlistmodel.dart';
import 'package:nex_music/model/saved_playlist_model.dart';
import 'package:nex_music/model/user_playlist_model.dart';
import '../widgets/user_playlist_tiles.dart';
import 'create_playlist_screen.dart';
import 'package:nex_music/presentation/library/widgets/sort_button.dart';
import 'package:nex_music/presentation/library/widgets/no_results_view.dart';

import 'package:nex_music/constants/enums.dart';

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
  String _searchQuery = '';
  PlaylistSortType _sortType = PlaylistSortType.timeDesc;

  @override
  void initState() {
    context.read<UserPlaylistBloc>().add(GetUserPlaylistsEvent());
    context.read<SavedPlaylistsBloc>().add(GetSavedPlaylistsEvent());
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

  List<UserPlaylistModel> _filterCreatedPlaylists(
      List<UserPlaylistModel> playlists) {
    List<UserPlaylistModel> result = playlists
        .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    switch (_sortType) {
      case PlaylistSortType.nameAsc:
        result.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case PlaylistSortType.nameDesc:
        result.sort(
            (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case PlaylistSortType.timeAsc:
        result.sort((a, b) {
          final timeA = a.timestamp is DateTime
              ? a.timestamp
              : (a.timestamp as dynamic).toDate();
          final timeB = b.timestamp is DateTime
              ? b.timestamp
              : (b.timestamp as dynamic).toDate();
          return timeA.compareTo(timeB);
        });
        break;
      case PlaylistSortType.timeDesc:
        result.sort((a, b) {
          final timeA = a.timestamp is DateTime
              ? a.timestamp
              : (a.timestamp as dynamic).toDate();
          final timeB = b.timestamp is DateTime
              ? b.timestamp
              : (b.timestamp as dynamic).toDate();
          return timeB.compareTo(timeA);
        });
        break;
    }
    return result;
  }

  List<SavedPlaylistModel> _filterSavedPlaylists(
      List<SavedPlaylistModel> playlists) {
    final filtered = playlists
        .where((p) =>
            !p.isAlbum &&
            p.playlistName.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    if (_sortType == PlaylistSortType.nameAsc ||
        _sortType == PlaylistSortType.nameDesc) {
      filtered.sort((a, b) => _sortType == PlaylistSortType.nameAsc
          ? a.playlistName.compareTo(b.playlistName)
          : b.playlistName.compareTo(a.playlistName));
    } else {
      filtered.sort((a, b) {
        final aTimestamp = a.timestamp;
        final bTimestamp = b.timestamp;

        if (aTimestamp == null || bTimestamp == null) return 0;

        DateTime aTime = aTimestamp is DateTime
            ? aTimestamp
            : (aTimestamp as dynamic).toDate();
        DateTime bTime = bTimestamp is DateTime
            ? bTimestamp
            : (bTimestamp as dynamic).toDate();

        return _sortType == PlaylistSortType.timeAsc
            ? aTime.compareTo(bTime)
            : bTime.compareTo(aTime);
      });
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final bool isNameActive = _sortType == PlaylistSortType.nameAsc ||
        _sortType == PlaylistSortType.nameDesc;
    final bool isTimeActive = _sortType == PlaylistSortType.timeAsc ||
        _sortType == PlaylistSortType.timeDesc;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
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
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Playlists",
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Row(
                    children: [
                      SortButton(
                        label: "Name",
                        isActive: isNameActive,
                        isDesc: _sortType == PlaylistSortType.nameDesc,
                        onTap: () {
                          setState(() {
                            _sortType = _sortType == PlaylistSortType.nameAsc
                                ? PlaylistSortType.nameDesc
                                : PlaylistSortType.nameAsc;
                          });
                        },
                      ),
                      const SizedBox(width: 15),
                      SortButton(
                        label: "Time",
                        isActive: isTimeActive,
                        isDesc: _sortType == PlaylistSortType.timeDesc,
                        onTap: () {
                          setState(() {
                            _sortType = _sortType == PlaylistSortType.timeDesc
                                ? PlaylistSortType.timeAsc
                                : PlaylistSortType.timeDesc;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Search Field
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: CupertinoSearchTextField(
                placeholder: 'Find in Playlists',
                cursorColor: Colors.red,
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
            // Tab Bar
            if (!widget.pickMode)
              TabBar(
                indicatorColor: Colors.red,
                labelColor: Colors.red,
                dividerColor: Colors.transparent,
                unselectedLabelColor: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
                tabs: const [
                  Tab(text: "Created"),
                  Tab(text: "Saved"),
                ],
              ),
            // Tab Content
            Expanded(
              child: widget.pickMode
                  ? _buildCreatedTab()
                  : TabBarView(
                      children: [
                        _buildCreatedTab(),
                        _buildSavedTab(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatedTab() {
    return BlocBuilder<UserPlaylistBloc, UserPlaylistState>(
      builder: (context, state) {
        if (state is UserPlaylistDataState) {
          return StreamBuilder<List<UserPlaylistModel>>(
            stream: state.data,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CupertinoActivityIndicator(
                        color: Colors.red, radius: 15));
              }
              final playlists = _filterCreatedPlaylists(snapshot.data ?? []);
              final gridItemCount = 1 + playlists.length;

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.82,
                ),
                itemCount: gridItemCount,
                itemBuilder: (context, index) {
                  if (index == 0)
                    return AddPlaylistTile(onTap: _showCreateDialog);
                  final playlist = playlists[index - 1];
                  final playlistName = playlist.name;
                  final colorValue = playlist.colorValue;
                  final displayMode = playlist.displayMode;
                  final thumbnails = playlist.thumbnails;

                  void onTap() {
                    if (widget.pickMode && widget.onPlaylistPicked != null) {
                      widget.onPlaylistPicked!(playlistName);
                      return;
                    }
                    String? thumbnail;
                    if (displayMode == 'dynamic' && thumbnails.isNotEmpty)
                      thumbnail = thumbnails.first;
                    context.pushNamed(RouterName.userPlaylistSongsName, extra: {
                      'name': playlistName,
                      'colorValue': colorValue,
                      if (thumbnail != null) 'thumbnail': thumbnail,
                    });
                  }

                  return UserPlaylistTile(
                    playlistName: playlistName,
                    color: Color(colorValue),
                    displayMode: displayMode,
                    thumbnails: thumbnails,
                    onTap: onTap,
                    onDelete: widget.pickMode
                        ? null
                        : () => _confirmDelete(playlistName),
                  );
                },
              );
            },
          );
        }
        return const Center(
            child: CupertinoActivityIndicator(color: Colors.red, radius: 15));
      },
    );
  }

  Widget _buildSavedTab() {
    return BlocBuilder<SavedPlaylistsBloc, SavedPlaylistsState>(
      builder: (context, state) {
        Stream<List<SavedPlaylistModel>>? stream;
        if (state is SavedPlaylistsDataState) {
          stream = state.playlists;
        } else if (state is IsPlaylistSavedState && state.playlists != null) {
          stream = state.playlists;
        }

        if (stream != null) {
          return StreamBuilder<List<SavedPlaylistModel>>(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CupertinoActivityIndicator(
                        color: Colors.red, radius: 15));
              }
              final allSavedItems = snapshot.data ?? [];
              final allSavedPlaylists =
                  allSavedItems.where((item) => !item.isAlbum).toList();
              final filteredPlaylists = _filterSavedPlaylists(allSavedItems);

              if (allSavedPlaylists.isEmpty) return const _EmptySavedView();
              if (filteredPlaylists.isEmpty)
                return NoResultsView(message: "No playlists match your search");

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 24,
                ),
                itemCount: filteredPlaylists.length,
                itemBuilder: (context, index) {
                  final playlist = filteredPlaylists[index];
                  return _SavedPlaylistTile(
                    playlist: playlist,
                    onTap: () {
                      final playListmodel = PlayListmodel(
                        playListId: playlist.playListId,
                        playlistName: playlist.playlistName,
                        artistBasic: playlist.artistBasic,
                        thumbnail: playlist.thumbnail,
                      );
                      context.push(RouterPath.showPlaylistSongsRoute, extra: {
                        'playlistData': playListmodel,
                        'isAlbum': playlist.isAlbum,
                      });
                    },
                    onRemove: () => _showRemoveDialog(context, playlist),
                  );
                },
              );
            },
          );
        }
        return const Center(
            child: CupertinoActivityIndicator(color: Colors.red, radius: 15));
      },
    );
  }

  void _showRemoveDialog(BuildContext context, SavedPlaylistModel playlist) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text("Remove Playlist"),
        content: Text(
            "Are you sure you want to remove \"${playlist.playlistName}\" from your library?"),
        actions: [
          CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              context.read<SavedPlaylistsBloc>().add(
                  RemoveFromSavedPlaylistsEvent(
                      playlistId: playlist.playListId));
              Navigator.pop(context);
            },
            child: const Text("Remove"),
          ),
        ],
      ),
    );
  }
}

class _SavedPlaylistTile extends StatelessWidget {
  final SavedPlaylistModel playlist;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _SavedPlaylistTile(
      {required this.playlist, required this.onTap, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onRemove,
      behavior: HitTestBehavior.translucent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    cacheImage(
                        imageUrl: playlist.thumbnail,
                        width: double.infinity,
                        height: double.infinity,
                        isRecommendedPlaylist: true),
                    Positioned(
                      top: 7,
                      right: 7,
                      child: GestureDetector(
                        onTap: onRemove,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              shape: BoxShape.circle),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              playlist.playlistName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: -0.5),
            ),
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              playlist.artistBasic.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.55),
                  fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySavedView extends StatelessWidget {
  const _EmptySavedView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.music_note_list,
              size: 80, color: Colors.red.withValues(alpha: 0.8)),
          const SizedBox(height: 20),
          Text(
            "Add Favorite Playlists",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'serif',
                fontSize: 22,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Playlists you save will appear here. Tap the + button on any playlist to save it to your library.",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 15,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
                height: 1.4),
          ),
        ],
      ),
    );
  }
}
