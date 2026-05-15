import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_music/bloc/saved_playlists_bloc/bloc/saved_playlists_bloc.dart';
import 'package:nex_music/constants/enums.dart';
import 'package:nex_music/core/route/go_router/go_router.dart';
import 'package:nex_music/core/ui_component/cacheimage.dart';
import 'package:nex_music/model/playlistmodel.dart';
import 'package:nex_music/model/saved_playlist_model.dart';
import 'package:nex_music/presentation/library/widgets/no_results_view.dart';
import 'package:nex_music/presentation/library/widgets/sort_button.dart';

class SavedAlbumsScreen extends StatefulWidget {
  const SavedAlbumsScreen({super.key});

  @override
  State<SavedAlbumsScreen> createState() => _SavedAlbumsScreenState();
}

class _SavedAlbumsScreenState extends State<SavedAlbumsScreen> {
  Stream<List<SavedPlaylistModel>>? _albumsStream;
  String _searchQuery = '';
  PlaylistSortType _sortType = PlaylistSortType.timeDesc;

  @override
  void initState() {
    super.initState();
    context.read<SavedPlaylistsBloc>().add(GetSavedPlaylistsEvent());
  }

  List<SavedPlaylistModel> _filterAlbums(List<SavedPlaylistModel> albums) {
    final filtered = albums
        .where((a) =>
            a.isAlbum &&
            a.playlistName.toLowerCase().contains(_searchQuery.toLowerCase()))
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

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () => context.pop(context),
          child: const Row(
            children: [
              SizedBox(width: 8),
              Icon(Icons.arrow_back_ios, color: Colors.red, size: 20),
              Text(
                'Library',
                style: TextStyle(color: Colors.red, fontSize: 17),
              ),
            ],
          ),
        ),
      ),
      body: BlocConsumer<SavedPlaylistsBloc, SavedPlaylistsState>(
        listener: (context, state) {
          if (state is SavedPlaylistsDataState) {
            setState(() {
              _albumsStream = state.playlists;
            });
          }
        },
        builder: (context, state) {
          Stream<List<SavedPlaylistModel>>? stream;
          if (state is SavedPlaylistsDataState) {
            stream = state.playlists;
          } else if (state is IsPlaylistSavedState && state.playlists != null) {
            stream = state.playlists;
          } else {
            stream = _albumsStream;
          }

          if (stream != null) {
            return StreamBuilder<List<SavedPlaylistModel>>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(
                      child: CupertinoActivityIndicator(
                    color: Colors.red,
                    radius: 15,
                  ));
                }

                final allSavedItems = snapshot.data ?? [];
                final allAlbums =
                    allSavedItems.where((item) => item.isAlbum).toList();
                final filteredAlbums = _filterAlbums(allSavedItems);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with Sort Buttons
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 16, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Albums",
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Row(
                            children: [
                              SortButton(
                                label: 'Name',
                                isActive: isNameActive,
                                isDesc: _sortType == PlaylistSortType.nameDesc,
                                onTap: () {
                                  setState(() {
                                    _sortType =
                                        _sortType == PlaylistSortType.nameAsc
                                            ? PlaylistSortType.nameDesc
                                            : PlaylistSortType.nameAsc;
                                  });
                                },
                              ),
                              const SizedBox(width: 15),
                              SortButton(
                                label: 'Time',
                                isActive: isTimeActive,
                                isDesc: _sortType == PlaylistSortType.timeDesc,
                                onTap: () {
                                  setState(() {
                                    _sortType =
                                        _sortType == PlaylistSortType.timeDesc
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

                    // Persistent Search Bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 15),
                      child: CupertinoSearchTextField(
                        placeholder: 'Search saved albums',
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                        cursorColor: Colors.red,
                      ),
                    ),

                    Expanded(
                      child: allAlbums.isEmpty
                          ? const _EmptyAlbumsView()
                          : filteredAlbums.isEmpty
                              ? NoResultsView(
                                  message: "No albums match your search")
                              : _AlbumsGridView(albums: filteredAlbums),
                    ),
                  ],
                );
              },
            );
          }
          return const Center(
              child: CupertinoActivityIndicator(
            color: Colors.red,
            radius: 15,
          ));
        },
      ),
    );
  }
}

class _AlbumsGridView extends StatelessWidget {
  final List<SavedPlaylistModel> albums;
  const _AlbumsGridView({required this.albums});

  void _showRemoveDialog(BuildContext context, SavedPlaylistModel album) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text("Remove Album"),
        content: Text(
            "Are you sure you want to remove \"${album.playlistName}\" from your library?"),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              context.read<SavedPlaylistsBloc>().add(
                  RemoveFromSavedPlaylistsEvent(playlistId: album.playListId));
              Navigator.pop(context);
            },
            child: const Text("Remove"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 24,
      ),
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final album = albums[index];
        return _SavedAlbumTile(
          album: album,
          onTap: () {
            final playListmodel = PlayListmodel(
              playListId: album.playListId,
              playlistName: album.playlistName,
              artistBasic: album.artistBasic,
              thumbnail: album.thumbnail,
            );
            context.push(
              RouterPath.showPlaylistSongsRoute,
              extra: {
                'playlistData': playListmodel,
                'isAlbum': true,
              },
            );
          },
          onRemove: () => _showRemoveDialog(context, album),
        );
      },
    );
  }
}

class _SavedAlbumTile extends StatelessWidget {
  final SavedPlaylistModel album;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _SavedAlbumTile({
    required this.album,
    required this.onTap,
    required this.onRemove,
  });

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
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    cacheImage(
                      imageUrl: album.thumbnail,
                      width: double.infinity,
                      height: double.infinity,
                      isRecommendedPlaylist: true,
                    ),
                    Positioned(
                      top: 7,
                      right: 7,
                      child: GestureDetector(
                        onTap: onRemove,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            shape: BoxShape.circle,
                          ),
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
              album.playlistName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              album.artistBasic.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.55),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyAlbumsView extends StatelessWidget {
  const _EmptyAlbumsView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.square_stack,
            size: 80,
            color: Colors.red.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 20),
          Text(
            "Add Your Favorite Albums",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 22,
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Albums you add will appear here. Tap the + button on any album to save it to your library.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// class _NoResultsView extends StatelessWidget {
//   const _NoResultsView();

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             CupertinoIcons.search,
//             size: 60,
//             color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             "No albums match your search",
//             style: TextStyle(
//               fontSize: 16,
//               color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
