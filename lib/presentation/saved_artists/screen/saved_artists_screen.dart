import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_music/bloc/saved_artists_bloc/bloc/saved_artists_bloc.dart';
import 'package:nex_music/constants/enums.dart';
import 'package:nex_music/model/artistmodel.dart';
import 'package:nex_music/presentation/library/widgets/no_results_view.dart';
import 'package:nex_music/presentation/library/widgets/sort_button.dart';
import 'package:nex_music/presentation/search/widgets/artistgridview.dart';

class SavedArtistsScreen extends StatefulWidget {
  const SavedArtistsScreen({super.key});

  @override
  State<SavedArtistsScreen> createState() => _SavedArtistsScreenState();
}

class _SavedArtistsScreenState extends State<SavedArtistsScreen> {
  Stream<List<ArtistModel>>? _artistsStream;
  String _searchQuery = '';
  PlaylistSortType _sortType = PlaylistSortType.nameAsc;

  @override
  void initState() {
    super.initState();
    context.read<SavedArtistsBloc>().add(GetSavedArtistsEvent());
  }

  List<ArtistModel> _filterArtists(List<ArtistModel> artists) {
    final filtered = artists
        .where((a) => (a.artist.name ?? '')
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();

    if (_sortType == PlaylistSortType.nameAsc ||
        _sortType == PlaylistSortType.nameDesc) {
      filtered.sort((a, b) => _sortType == PlaylistSortType.nameAsc
          ? (a.artist.name ?? '').compareTo(b.artist.name ?? '')
          : (b.artist.name ?? '').compareTo(a.artist.name ?? ''));
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
      body: BlocConsumer<SavedArtistsBloc, SavedArtistsState>(
        listener: (context, state) {
          if (state is SavedArtistsDataState) {
            setState(() {
              _artistsStream = state.artists;
            });
          }
        },
        builder: (context, state) {
          if (_artistsStream != null) {
            return StreamBuilder<List<ArtistModel>>(
              stream: _artistsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(
                      child: CupertinoActivityIndicator(
                    color: Colors.red,
                    radius: 15,
                  ));
                }

                final allArtists = snapshot.data ?? [];
                final filteredArtists = _filterArtists(allArtists);

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
                            "Artists",
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

                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 15),
                      child: CupertinoSearchTextField(
                        placeholder: 'Search saved artists',
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                        cursorColor: Colors.red,
                      ),
                    ),

                    Expanded(
                      child: allArtists.isEmpty
                          ? const _EmptyArtistsView()
                          : filteredArtists.isEmpty
                              ? NoResultsView(
                                  message: "No artists match your search")
                              : _ArtistsGridView(artists: filteredArtists),
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

class _ArtistsGridView extends StatelessWidget {
  final List<ArtistModel> artists;
  const _ArtistsGridView({required this.artists});

  void _showRemoveDialog(BuildContext context, ArtistModel artist) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text("Remove Artist"),
        content: Text(
            "Are you sure you want to remove ${artist.artist.name} from your library?"),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              context.read<SavedArtistsBloc>().add(RemoveFromSavedArtistsEvent(
                  artistId: artist.artist.artistId ?? ''));
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
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: artists.length,
      itemBuilder: (context, index) {
        final artist = artists[index];
        return ArtistGridView(
          artist: artist,
          onRemove: () => _showRemoveDialog(context, artist),
        );
      },
    );
  }
}

class _EmptyArtistsView extends StatelessWidget {
  const _EmptyArtistsView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.person,
            size: 80,
            color: Colors.red.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 20),
          Text(
            "Add Your Favorite Artists",
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
            "Artists you add will appear here along with artists from music in your library.",
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
