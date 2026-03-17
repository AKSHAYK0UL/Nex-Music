import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nex_music/enum/tab_route.dart';
import 'package:nex_music/model/songmodel.dart';

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
          final DateTime timeA =
              a.timestamp is DateTime ? a.timestamp as DateTime : DateTime(0);
          final DateTime timeB =
              b.timestamp is DateTime ? b.timestamp as DateTime : DateTime(0);
          return timeA.compareTo(timeB);
        });
        break;
      case SongSortType.timeDesc:
        result.sort((a, b) {
          final DateTime timeA =
              a.timestamp is DateTime ? a.timestamp as DateTime : DateTime(0);
          final DateTime timeB =
              b.timestamp is DateTime ? b.timestamp as DateTime : DateTime(0);
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

    return Scaffold(
      backgroundColor: Colors.white,
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
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Row(
                    children: [
                      _SortButton(
                        label: "Name",
                        isActive: isNameActive,
                        isDesc: _sortType == SongSortType.nameDesc,
                        onTap: _toggleNameSort,
                      ),
                      const SizedBox(width: 12),
                      _SortButton(
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
              child: widget.builder(context, _filteredSongs),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isDesc;
  final VoidCallback onTap;

  const _SortButton({
    required this.label,
    required this.isActive,
    required this.isDesc,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? Colors.black : Colors.grey,
            ),
          ),
          if (isActive) ...[
            const SizedBox(width: 2),
            Icon(
              isDesc ? CupertinoIcons.arrow_down : CupertinoIcons.arrow_up,
              size: 14,
              color: Colors.black,
            ),
          ]
        ],
      ),
    );
  }
}
