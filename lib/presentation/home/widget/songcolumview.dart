import 'package:flutter/material.dart';

import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/home/widget/song_title.dart';

class SongColumView extends StatelessWidget {
  final int rowIndex;
  final int quickPicksLength;
  final List<Songmodel> quickPicks;
  const SongColumView({
    required this.rowIndex,
    required this.quickPicksLength,
    required this.quickPicks,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;

    return SizedBox(
      width: screenSize * 0.43,
      child: Column(
        children: List.generate(
          4,
          (columnIndex) {
            final index =
                rowIndex * 4 + columnIndex; // Calculate the actual index
            if (index < quickPicksLength) {
              final songData = quickPicks[index];
              return SongTitle(songData: songData);
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }
}
