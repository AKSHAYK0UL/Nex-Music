import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_music/bloc/favorites_songs_bloc/bloc/favorites_songs_bloc.dart';
import 'package:nex_music/core/wrapper/song_filter_wrapper.dart';
import 'package:nex_music/enum/tab_route.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/recent/widgets/recent_song_tile.dart';

class FavoritesSongsScreen extends StatefulWidget {
  const FavoritesSongsScreen({super.key});

  @override
  State<FavoritesSongsScreen> createState() => _FavoritesSongsScreenState();
}

class _FavoritesSongsScreenState extends State<FavoritesSongsScreen> {
  @override
  void initState() {
    context.read<FavoritesSongsBloc>().add(GetFavoritesEvent());
    super.initState();
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
      body: BlocBuilder<FavoritesSongsBloc, FavoritesSongsState>(
        builder: (context, state) {
          if (state is FavortiesSongsDataState) {
            return StreamBuilder<List<Songmodel>>(
              stream: state.songs,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CupertinoActivityIndicator(
                      color: Colors.red,
                      radius: 15,
                    ),
                  );
                }

                final favoritesSongs = snapshot.data ?? [];

                // Use the Wrapper Class here
                return SongFilterWrapper(
                  title: "Favorites",
                  songs: favoritesSongs,
                  tabRoute: TabRouteENUM.favorites,
                  builder: (context, filteredSongs) {
                    if (filteredSongs.isEmpty) {
                      return const _EmptyFavoritesView();
                    }

                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: filteredSongs.length,
                      itemBuilder: (context, index) {
                        return RecentSongTile(
                          songData: filteredSongs[index],
                          songIndex: index,
                          tabRouteENUM: TabRouteENUM.favorites,
                        );
                      },
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

class _EmptyFavoritesView extends StatelessWidget {
  const _EmptyFavoritesView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.heart,
              size: 80,
              color: Colors.red.withValues(alpha:0.8),
            ),
            const SizedBox(height: 25),
            const Text(
              "Add Your Favorite Songs",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Songs you mark as favorite will appear here so you can find them easily.",
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
      ),
    );
  }
}