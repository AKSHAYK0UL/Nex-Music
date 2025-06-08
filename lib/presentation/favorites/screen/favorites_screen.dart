import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/favorites_songs_bloc/bloc/favorites_songs_bloc.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/core/ui_component/snackbar.dart';
import 'package:nex_music/enum/tab_route.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/home/widget/song_title.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  ValueNotifier<bool> switchState = ValueNotifier(false);
  List<Songmodel> favoritesSongs = [];

  @override
  void initState() {
    context.read<FavoritesSongsBloc>().add(GetFavoritesEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.only(left: screenSize * 0.0131),
          child: Text(
            "Favorites",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        actions: [
          ValueListenableBuilder(
            valueListenable: switchState,
            builder: (__, ___, _) {
              return Padding(
                padding: EdgeInsets.only(right: screenSize * 0.0131),
                child: IconButton(
                  onPressed: () {
                    switchState.value = !switchState.value;
                    if (switchState.value) {
                      context.read<SongstreamBloc>().add(ResetPlaylistEvent());
                      context.read<SongstreamBloc>().add(GetSongPlaylistEvent(
                          songlist:
                              favoritesSongs)); //load recent songs in the playlist
                      showSnackbar(context, "Now playing your favorite songs");
                    } else {
                      context.read<SongstreamBloc>().add(CleanPlaylistEvent());
                    }
                  },
                  icon: Icon(
                    Icons.queue_music,
                    size: screenSize * 0.038,
                    color: switchState.value ? accentColor : Colors.grey,
                  ),
                ),
              );
            },
          )
        ],
      ),
      body: BlocBuilder<FavoritesSongsBloc, FavoritesSongsState>(
        buildWhen: (previous, current) => previous != current,
        builder: (context, state) {
          if (state is FavortiesSongsDataState) {
            return Padding(
              padding: EdgeInsets.only(
                right: screenSize * 0.0131,
                left: screenSize * 0.0131,
                top: screenSize * 0.0131,
              ),
              child: StreamBuilder(
                stream: state.songs,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(snapshot.error.toString()),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No Favorite songs'));
                  } else {
                    final songsData = snapshot.data!;
                    favoritesSongs = songsData;
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: songsData.length,
                      itemBuilder: (context, index) {
                        final songData = songsData[index];
                        return SongTitle(
                          songData: songData,
                          songIndex: index,
                          showDelete: true,
                          tabRouteENUM: TabRouteENUM.favorites,
                        );
                      },
                    );
                  }
                },
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
