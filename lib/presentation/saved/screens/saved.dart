
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_music/bloc/homesection_bloc/homesection_bloc.dart';
import 'package:nex_music/bloc/offline_songs_bloc/bloc/offline_songs_bloc.dart';
import 'package:nex_music/core/route/go_router/go_router.dart';
import 'package:nex_music/core/ui_component/snackbar.dart';
import 'package:nex_music/core/wrapper/song_filter_wrapper.dart';
import 'package:nex_music/enum/tab_route.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/audio_player/widget/miniplayer.dart';
import 'package:nex_music/presentation/recent/widgets/recent_song_tile.dart';

class SavedSongs extends StatefulWidget {
  final bool isoffline;
  const SavedSongs({super.key, required this.isoffline});

  @override
  State<SavedSongs> createState() => _SavedSongsState();
}

class _SavedSongsState extends State<SavedSongs> {
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OfflineSongsBloc>().add(LoadOfflineSongsEvent());
    });
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _onRefreshPressed() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);

    final hasInternet = await _checkInternetConnection();

    if (!mounted) return;

    if (hasInternet) {
      // Re-trigger home data fetch, which will navigate back to home on success
      context.read<HomesectionBloc>().add(GetHomeSectonDataEvent());
      AppRouter.router.go(RouterPath.homeRoute);
    } else {
      showSnackbar(context, "No internet connection");
    }

    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: widget.isoffline ? 0 : 100,
        leading: widget.isoffline
            ? const SizedBox.shrink()
            : GestureDetector(
                onTap: () => context.pop(),
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
        actions: widget.isoffline
            ? [
                _isRefreshing
                    ? const Padding(
                        padding: EdgeInsets.only(right: 16.0),
                        child: CupertinoActivityIndicator(
                          color: Colors.red,
                          radius: 10,
                        ),
                      )
                    : IconButton(
                        onPressed: _onRefreshPressed,
                        icon: const Icon(
                          CupertinoIcons.refresh,
                          color: Colors.red,
                          size: 22,
                        ),
                      ),
              ]
            : null,
      ),
      body: BlocBuilder<OfflineSongsBloc, OfflineSongsState>(
        builder: (context, state) {
          if (state is OfflineSongsLoadingState) {
            return const Center(
              child: CupertinoActivityIndicator(color: Colors.red, radius: 15),
            );
          }

          if (state is OfflineSongsErrorState) {
            return Center(
              child: Text(state.errorMessage,
                  style: const TextStyle(color: Colors.red)),
            );
          }

          if (state is OfflineSongsDataState) {
            return StreamBuilder<List<Songmodel>>(
              stream: state.data,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CupertinoActivityIndicator(
                        color: Colors.red, radius: 15),
                  );
                }

                final allDownloadedSongs = snapshot.data ?? [];

                // Use the Wrapper to handle search and sort logic
                return SongFilterWrapper(
                  title: "Downloads",
                  songs: allDownloadedSongs,
                  tabRoute: TabRouteENUM.download,
                  builder: (context, filteredSongs) {
                    if (filteredSongs.isEmpty) {
                      return const _EmptyDownloadsView();
                    }

                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: filteredSongs.length,
                      itemBuilder: (context, index) {
                        return RecentSongTile(
                          songData: filteredSongs[index],
                          songIndex: index,
                          tabRouteENUM: TabRouteENUM.download,
                          playlistSongs: filteredSongs,
                        );
                      },
                    );
                  },
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
      bottomNavigationBar: widget.isoffline
          ? MiniPlayer(screenSize: MediaQuery.sizeOf(context).height)
          : const SizedBox(),
    );
  }
}

class _EmptyDownloadsView extends StatelessWidget {
  const _EmptyDownloadsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.cloud_download,
              size: 80,
              color: Colors.red.withOpacity(0.8),
            ),
            const SizedBox(height: 25),
            const Text(
              "No Downloads Found",
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
              "Music you've downloaded will appear here so you can listen even when you're offline.",
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
