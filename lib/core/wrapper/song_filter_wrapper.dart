import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nex_music/enum/tab_route.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/library/widgets/no_results_view.dart';
import 'package:nex_music/presentation/library/widgets/sort_button.dart';

enum SongSortType {
  nameAsc,
  nameDesc,
  timeAsc,
  timeDesc,
}

typedef SongListBuilder = Widget Function(
  BuildContext context,
  List<Songmodel> filteredSongs,
);

class SongFilterWrapper extends StatefulWidget {
  final String title;
  final List<Songmodel> songs;
  final TabRouteENUM tabRoute;
  final SongListBuilder builder;

  const SongFilterWrapper({
    super.key,
    required this.title,
    required this.songs,
    required this.tabRoute,
    required this.builder,
  });

  @override
  State<SongFilterWrapper> createState() => _SongFilterWrapperState();
}

class _SongFilterWrapperState extends State<SongFilterWrapper> {
  String _searchQuery = '';

  SongSortType _sortType = SongSortType.timeDesc;

  List<Songmodel> get _filteredSongs {
    List<Songmodel> result = widget.songs
        .where((song) =>
            song.songName.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    switch (_sortType) {
      case SongSortType.nameAsc:
        result.sort((a, b) =>
            a.songName.toLowerCase().compareTo(b.songName.toLowerCase()));
        break;
      case SongSortType.nameDesc:
        result.sort((a, b) =>
            b.songName.toLowerCase().compareTo(a.songName.toLowerCase()));
        break;
      case SongSortType.timeAsc:
        result.sort((a, b) {
          final aTimestamp = a.timestamp;
          final bTimestamp = b.timestamp;

          if (aTimestamp == null || bTimestamp == null) return 0;

          DateTime timeA = aTimestamp is DateTime 
              ? aTimestamp 
              : (aTimestamp as dynamic).toDate();
          DateTime timeB = bTimestamp is DateTime 
              ? bTimestamp 
              : (bTimestamp as dynamic).toDate();
          return timeA.compareTo(timeB);
        });
        break;
      case SongSortType.timeDesc:
        result.sort((a, b) {
          final aTimestamp = a.timestamp;
          final bTimestamp = b.timestamp;

          if (aTimestamp == null || bTimestamp == null) return 0;

          DateTime timeA = aTimestamp is DateTime 
              ? aTimestamp 
              : (aTimestamp as dynamic).toDate();
          DateTime timeB = bTimestamp is DateTime 
              ? bTimestamp 
              : (bTimestamp as dynamic).toDate();
          return timeB.compareTo(timeA);
        });
        break;
    }
    return result;
  }

  void _toggleNameSort() {
    setState(() {
      if (_sortType == SongSortType.nameAsc) {
        _sortType = SongSortType.nameDesc;
      } else {
        _sortType = SongSortType.nameAsc;
      }
    });
  }

  void _toggleTimeSort() {
    setState(() {
      if (_sortType == SongSortType.timeDesc) {
        _sortType = SongSortType.timeAsc;
      } else {
        _sortType = SongSortType.timeDesc;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isNameActive =
        _sortType == SongSortType.nameAsc || _sortType == SongSortType.nameDesc;
    final bool isTimeActive =
        _sortType == SongSortType.timeAsc || _sortType == SongSortType.timeDesc;

    final List<Songmodel> filteredSongs = _filteredSongs;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.title,
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
                        isDesc: _sortType == SongSortType.nameDesc,
                        onTap: _toggleNameSort,
                      ),
                      const SizedBox(width: 15),
                      SortButton(
                        label: "Time",
                        isActive: isTimeActive,
                        isDesc: _sortType == SongSortType.timeDesc,
                        onTap: _toggleTimeSort,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              child: CupertinoSearchTextField(
                placeholder: 'Find in ${widget.title}',
                cursorColor: Colors.red,
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
            ),
            Expanded(
              child: (filteredSongs.isEmpty && _searchQuery.isNotEmpty)
                  ? NoResultsView(message: "No songs match your search")
                  : widget.builder(context, filteredSongs),
            ),
          ],
        ),
      ),
    );
  }
}
