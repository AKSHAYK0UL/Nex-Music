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
import 'package:nex_music/enum/tab_route.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/audio_player/widget/miniplayer.dart';
import 'package:nex_music/presentation/library/widgets/sort_button.dart';
import 'package:nex_music/presentation/recent/widgets/recent_song_tile.dart';
import 'package:nex_music/presentation/saved/widgets/active_download_tile.dart';

//  Sort enum 
enum _SortType { nameAsc, nameDesc, timeAsc, timeDesc }


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

  Future<bool> _checkInternet() async {
    try {
      final r = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return r.isNotEmpty && r[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _onRefresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    final ok = await _checkInternet();
    if (!mounted) return;
    if (ok) {
      context.read<HomesectionBloc>().add(GetHomeSectonDataEvent());
      AppRouter.router.go(RouterPath.homeRoute);
    } else {
      showSnackbar(context, 'No internet connection');
    }
    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                    Text('Library',
                        style: TextStyle(color: Colors.red, fontSize: 17)),
                  ],
                ),
              ),
        actions: widget.isoffline
            ? [
                _isRefreshing
                    ? const Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: CupertinoActivityIndicator(
                            color: Colors.red, radius: 10),
                      )
                    : IconButton(
                        onPressed: _onRefresh,
                        icon: const Icon(CupertinoIcons.refresh,
                            color: Colors.red, size: 22),
                      ),
              ]
            : null,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Downloads',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
             
                _SortButtons(notifier: _sortNotifier),
              ],
            ),
          ),

          // Search field shared, matches Playlists screen 
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: CupertinoSearchTextField(
              controller: _searchController,
              placeholder: 'Find in Downloads',
              cursorColor: Colors.red,
              onChanged: (v) => _searchNotifier.value = v,
            ),
          ),

          // Tab bar 
          BlocBuilder<DownloadManagerBloc, DownloadManagerState>(
            buildWhen: (p, c) =>
                p.activeTasks.length != c.activeTasks.length,
            builder: (context, dmState) {
              final count = dmState.activeTasks.length;
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
                        if (count > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$count',
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
                _DownloadedTab(
                  searchNotifier: _searchNotifier,
                  sortNotifier: _sortNotifier,
                ),
                _PendingTab(searchNotifier: _searchNotifier),
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
    );
  }

  // Shared state for search and sort, passed into both tabs via ValueNotifier
  final _searchNotifier = ValueNotifier<String>('');
  final _sortNotifier = ValueNotifier<_SortType>(_SortType.timeDesc);
  final _searchController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }
}

// Sort buttons widget 
class _SortButtons extends StatefulWidget {
  final ValueNotifier<_SortType> notifier;
  const _SortButtons({required this.notifier});

  @override
  State<_SortButtons> createState() => _SortButtonsState();
}

class _SortButtonsState extends State<_SortButtons> {
  @override
  void initState() {
    super.initState();
    widget.notifier.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    widget.notifier.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sort = widget.notifier.value;
    final isName =
        sort == _SortType.nameAsc || sort == _SortType.nameDesc;
    final isTime =
        sort == _SortType.timeAsc || sort == _SortType.timeDesc;

    return Row(
      children: [
        SortButton(
          label: 'Name',
          isActive: isName,
          isDesc: sort == _SortType.nameDesc,
          onTap: () {
            widget.notifier.value = sort == _SortType.nameAsc
                ? _SortType.nameDesc
                : _SortType.nameAsc;
          },
        ),
        const SizedBox(width: 15),
        SortButton(
          label: 'Time',
          isActive: isTime,
          isDesc: sort == _SortType.timeDesc,
          onTap: () {
            widget.notifier.value = sort == _SortType.timeDesc
                ? _SortType.timeAsc
                : _SortType.timeDesc;
          },
        ),
      ],
    );
  }
}

// Tab 1 Downloaded songs
class _DownloadedTab extends StatefulWidget {
  final ValueNotifier<String> searchNotifier;
  final ValueNotifier<_SortType> sortNotifier;

  const _DownloadedTab({
    required this.searchNotifier,
    required this.sortNotifier,
  });

  @override
  State<_DownloadedTab> createState() => _DownloadedTabState();
}

class _DownloadedTabState extends State<_DownloadedTab> {
  @override
  void initState() {
    super.initState();
    widget.searchNotifier.addListener(_rebuild);
    widget.sortNotifier.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    widget.searchNotifier.removeListener(_rebuild);
    widget.sortNotifier.removeListener(_rebuild);
    super.dispose();
  }

  List<Songmodel> _apply(List<Songmodel> songs) {
    final q = widget.searchNotifier.value.toLowerCase();
    List<Songmodel> result = q.isEmpty
        ? List.from(songs)
        : songs
            .where((s) => s.songName.toLowerCase().contains(q))
            .toList();

    switch (widget.sortNotifier.value) {
      case _SortType.nameAsc:
        result.sort((a, b) =>
            a.songName.toLowerCase().compareTo(b.songName.toLowerCase()));
        break;
      case _SortType.nameDesc:
        result.sort((a, b) =>
            b.songName.toLowerCase().compareTo(a.songName.toLowerCase()));
        break;
      case _SortType.timeAsc:
        result.sort((a, b) => _ts(a).compareTo(_ts(b)));
        break;
      case _SortType.timeDesc:
        result.sort((a, b) => _ts(b).compareTo(_ts(a)));
        break;
    }
    return result;
  }

  DateTime _ts(Songmodel s) {
    final t = s.timestamp;
    if (t == null) return DateTime.fromMillisecondsSinceEpoch(0);
    try {
      // Firestore Timestamp has a .toDate() method
      return (t as dynamic).toDate() as DateTime;
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }
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
          final filtered = _apply(state.songs);

          if (filtered.isEmpty) {
            return const _EmptyDownloadsView();
          }

          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: filtered.length,
            itemBuilder: (context, index) => RecentSongTile(
              songData: filtered[index],
              songIndex: index,
              tabRouteENUM: TabRouteENUM.download,
              playlistSongs: filtered,
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}

// Tab 2 Pending / in-progress downloads
class _PendingTab extends StatefulWidget {
  final ValueNotifier<String> searchNotifier;
  const _PendingTab({required this.searchNotifier});

  @override
  State<_PendingTab> createState() => _PendingTabState();
}

class _PendingTabState extends State<_PendingTab> {
  @override
  void initState() {
    super.initState();
    widget.searchNotifier.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    widget.searchNotifier.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloadManagerBloc, DownloadManagerState>(
      builder: (context, state) {
        final q = widget.searchNotifier.value.toLowerCase();
        final tasks = state.activeTasks.where((t) {
          return q.isEmpty ||
              t.songData.songName.toLowerCase().contains(q);
        }).toList();

        if (tasks.isEmpty) {
          return const _EmptyPendingView();
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
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

// Empty states
class _EmptyDownloadsView extends StatelessWidget {
  const _EmptyDownloadsView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.cloud_download,
                    size: 80, color: Colors.red.withValues(alpha: 0.8)),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyPendingView extends StatelessWidget {
  const _EmptyPendingView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.downloading_rounded,
                    size: 80, color: Colors.red.withValues(alpha: 0.8)),
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
                  'Songs currently downloading, paused, or pending will appear here.',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
