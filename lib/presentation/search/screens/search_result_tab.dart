import 'package:flutter/material.dart';
import 'package:nex_music/enum/segment_button_value.dart';
import 'package:nex_music/presentation/audio_player/widget/miniplayer.dart';
import 'package:nex_music/presentation/search/screens/tabs/songstab.dart';
import 'package:nex_music/presentation/search/screens/tabs/videostab.dart';

class SearchResultTab extends StatefulWidget {
  static const routeName = "/searchresulttab";
  const SearchResultTab({super.key});

  @override
  State<SearchResultTab> createState() => _SearchResultTabState();
}

class _SearchResultTabState extends State<SearchResultTab> {
  SegmentButtonValue selectedSegment = SegmentButtonValue.songs;
  List<Widget> tabs = [
    const SongsTab(),
    const Videostab(),
    const SongsTab(),
    const SongsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Results"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: screenSize * 0.0175),
              width: double.infinity,
              child: SegmentedButton<SegmentButtonValue>(
                showSelectedIcon: false,
                segments: <ButtonSegment<SegmentButtonValue>>[
                  ButtonSegment(
                    value: SegmentButtonValue.songs,
                    label: Text(
                      'Songs',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  ButtonSegment(
                    value: SegmentButtonValue.videos,
                    label: Text(
                      'Videos',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  ButtonSegment(
                    value: SegmentButtonValue.playlists,
                    label: Text(
                      'Playlists',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  ButtonSegment(
                    value: SegmentButtonValue.artist,
                    label: Text(
                      'Artist',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ],
                selected: <SegmentButtonValue>{selectedSegment},
                onSelectionChanged: (newSelection) {
                  setState(
                    () {
                      selectedSegment = newSelection.first;
                    },
                  );
                },
              ),
            ),
            IndexedStack(
              index: selectedSegment.index,
              children: tabs,
            )
          ],
        ),
      ),
      bottomNavigationBar: MiniPlayer(screenSize: screenSize),
    );
  }
}
