
import 'package:flutter/cupertino.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_music/bloc/saved_artists_bloc/bloc/saved_artists_bloc.dart';

import 'package:nex_music/model/artistmodel.dart';
import 'package:nex_music/presentation/search/widgets/artistgridview.dart';

class SavedArtistsScreen extends StatefulWidget {
  const SavedArtistsScreen({super.key});

  @override
  State<SavedArtistsScreen> createState() => _SavedArtistsScreenState();
}

class _SavedArtistsScreenState extends State<SavedArtistsScreen> {
  Stream<List<ArtistModel>>? _artistsStream;

  @override
  void initState() {
    super.initState();
    context.read<SavedArtistsBloc>().add(GetSavedArtistsEvent());
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
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CupertinoActivityIndicator(
                    color: Colors.red.withValues(alpha: 0.8),
                    radius: 15,
                  ));
                }

                final artists = snapshot.data ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 24.0, bottom: 10.0),
                      child: Text(
                        "Artists",
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 7),
                      child: CupertinoSearchTextField(
                        placeholder: 'Find in Artists',
                        cursorColor: Colors.red,
                      ),
                    ),
                    Expanded(
                      child: artists.isEmpty
                          ? const _EmptyArtistsView()
                          : _ArtistsGridView(artists: artists),
                    ),
                  ],
                );
              },
            );
          }
          return Center(
              child: CupertinoActivityIndicator(
            color: Colors.red.withValues(alpha: 0.8), 
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
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
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
          const Text(
            "Add Your Favorite Artists",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 22,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Artists you add will appear here along with artists from music in your library.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
