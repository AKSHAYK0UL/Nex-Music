import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nex_music/model/user_playlist_model.dart';

enum PlaylistSortType {
  nameAsc,
  nameDesc,
  timeAsc,
  timeDesc,
}

typedef PlaylistListBuilder = Widget Function(
  BuildContext context,
  List<UserPlaylistModel> filteredPlaylists,
);

class PlaylistFilterWrapper extends StatefulWidget {
  final String title;
  final List<UserPlaylistModel> playlists;
  final PlaylistListBuilder builder;

  const PlaylistFilterWrapper({
    super.key,
    required this.title,
    required this.playlists,
    required this.builder,
  });

  @override
  State<PlaylistFilterWrapper> createState() => _PlaylistFilterWrapperState();
}

class _PlaylistFilterWrapperState extends State<PlaylistFilterWrapper> {
  String _searchQuery = '';

  PlaylistSortType _sortType = PlaylistSortType.timeDesc;

  List<UserPlaylistModel> get _filteredPlaylists {
    List<UserPlaylistModel> result = widget.playlists
        .where((playlist) =>
            playlist.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    switch (_sortType) {
      case PlaylistSortType.nameAsc:
        result.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case PlaylistSortType.nameDesc:
        result.sort(
            (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case PlaylistSortType.timeAsc:
        result.sort((a, b) {
          final dynamic timeA = a.timestamp;
          final dynamic timeB = b.timestamp;

          if (timeA == null) return 1;
          if (timeB == null) return -1;

          final DateTime dtA =
              timeA is DateTime ? timeA : (timeA as dynamic).toDate();
          final DateTime dtB =
              timeB is DateTime ? timeB : (timeB as dynamic).toDate();

          return dtA.compareTo(dtB);
        });
        break;
      case PlaylistSortType.timeDesc:
        result.sort((a, b) {
          final dynamic timeA = a.timestamp;
          final dynamic timeB = b.timestamp;

          if (timeA == null) return 1;
          if (timeB == null) return -1;

          final DateTime dtA =
              timeA is DateTime ? timeA : (timeA as dynamic).toDate();
          final DateTime dtB =
              timeB is DateTime ? timeB : (timeB as dynamic).toDate();

          return dtB.compareTo(dtA);
        });
        break;
    }
    return result;
  }

  void _toggleNameSort() {
    setState(() {
      if (_sortType == PlaylistSortType.nameAsc) {
        _sortType = PlaylistSortType.nameDesc;
      } else {
        _sortType = PlaylistSortType.nameAsc;
      }
    });
  }

  void _toggleTimeSort() {
    setState(() {
      if (_sortType == PlaylistSortType.timeDesc) {
        _sortType = PlaylistSortType.timeAsc;
      } else {
        _sortType = PlaylistSortType.timeDesc;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isNameActive = _sortType == PlaylistSortType.nameAsc ||
        _sortType == PlaylistSortType.nameDesc;
    final bool isTimeActive = _sortType == PlaylistSortType.timeAsc ||
        _sortType == PlaylistSortType.timeDesc;

    return Column(
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
                    isDesc: _sortType == PlaylistSortType.nameDesc,
                    onTap: _toggleNameSort,
                  ),
                  const SizedBox(width: 12),
                  _SortButton(
                    label: "Time",
                    isActive: isTimeActive,
                    isDesc: _sortType == PlaylistSortType.timeDesc,
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
          child: widget.builder(context, _filteredPlaylists),
        ),
      ],
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
