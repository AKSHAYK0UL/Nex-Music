import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_music/bloc/download_manager_bloc/bloc/download_manager_bloc.dart';
import 'package:nex_music/bloc/homesection_bloc/homesection_bloc.dart';
import 'package:nex_music/bloc/offline_songs_bloc/bloc/offline_songs_bloc.dart';
import 'package:nex_music/core/route/go_router/go_router.dart';
import 'package:nex_music/core/ui_component/snackbar.dart';
import 'package:nex_music/core/wrapper/song_filter_wrapper.dart';
import 'package:nex_music/enum/tab_route.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/audio_player/widget/miniplayer.dart';
import 'package:nex_music/presentation/recent/widgets/recent_song_tile.dart';
import 'package:nex_music/presentation/saved/widgets/active_download_tile.dart';

class SavedSongs extends StatefulWidget {
  final bool isoffline;
  const SavedSongs({super.key, required this.isoffline});

  @override
  State<SavedSongs> createState() => _SavedSongsState();
}

class _SavedSongsState extends State<SavedSongs>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OfflineSongsBloc>().add(LoadOfflineSongsEvent());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      context.read<HomesectionBloc>().add(GetHomeSectonDataEvent());
      AppRouter.router.go(RouterPath.homeRoute);
    } else {
      showSnackbar(context, "No internet connection");
    }

    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title 
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Text(
                'Downloads',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            // Tab bar 
            BlocBuilder<DownloadManagerBloc, DownloadManagerState>(
              buildWhen: (prev, curr) =>
                  prev.activeTasks.length != curr.activeTasks.length,
              builder: (context, dmState) {
                final pendingCount = dmState.activeTasks.length;
                return TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.red,
                  labelColor: Colors.red,
                  dividerColor: Colors.transparent,
                  unselectedLabelColor: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                  tabs: [
                    const Tab(text: 'Saved'),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Pending'),
                          if (pendingCount > 0) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$pendingCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

            // Tab views 
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _DownloadedTab(),
                  _PendingTab(),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: widget.isoffline
            ? SafeArea(
                child: MiniPlayer(
                    screenSize: MediaQuery.sizeOf(context).height))
            : const SizedBox(),
      ),
    );
  }
}


// Tab 1 Downloaded songs
class _DownloadedTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OfflineSongsBloc, OfflineSongsState>(
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

              final songs = snapshot.data ?? [];

              return SongFilterWrapper(
                title: '',
                songs: songs,
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
    );
  }
}

// Tab 2 — Pending / in-progress downloads
class _PendingTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloadManagerBloc, DownloadManagerState>(
      builder: (context, state) {
        final tasks = state.activeTasks;

        if (tasks.isEmpty) {
          return const _EmptyPendingView();
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            // Rebuild each tile only when its own task changes.
            return BlocBuilder<DownloadManagerBloc, DownloadManagerState>(
              buildWhen: (prev, curr) =>
                  prev.task(task.songData.vId) !=
                  curr.task(task.songData.vId),
              builder: (context, s) {
                final current = s.task(task.songData.vId);
                if (current == null) return const SizedBox.shrink();
                return ActiveDownloadTile(task: current);
              },
            );
          },
        );
      },
    );
  }
}

// Empty state views
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
              color: Colors.red.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 25),
            Text(
              'No Downloads Yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Music you've downloaded will appear here so you can listen even when you're offline.",
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
      ),
    );
  }
}

class _EmptyPendingView extends StatelessWidget {
  const _EmptyPendingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.checkmark_circle,
              size: 80,
              color: Colors.green.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 25),
            Text(
              'Nothing Downloading',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Songs you download will appear here while in progress.',
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
      ),
    );
  }
}
