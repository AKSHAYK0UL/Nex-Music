import 'package:flutter/material.dart';

import 'package:nex_music/core/services/hive_singleton.dart';
import 'package:nex_music/core/ui_component/animatedtext.dart';
import 'package:nex_music/core/ui_component/cacheimage.dart';
import 'package:nex_music/enum/quality.dart';
import 'package:nex_music/enum/song_miniplayer_route.dart';
import 'package:nex_music/enum/tab_route.dart';
import 'package:nex_music/helper_function/route.dart';
import 'package:nex_music/main.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/audio_player/widget/overlay_audio_player.dart';
import 'package:nex_music/presentation/home/navbar/screen/navbar.dart';
import 'package:nex_music/presentation/home/widget/longpress_options_bottom_sheet.dart';
import 'package:nex_music/presentation/home/widget/long_press_options.dart';

class SongTitle extends StatefulWidget {
  final Songmodel songData;
  final int songIndex;
  final bool showDelete;
  final TabRouteENUM tabRouteENUM;
  final String? playlistName;

  const SongTitle({
    super.key,
    required this.songData,
    required this.songIndex,
    required this.showDelete,
    required this.tabRouteENUM,
    this.playlistName,
  });

  @override
  State<SongTitle> createState() => _SongTitleState();
}

class _SongTitleState extends State<SongTitle> with TickerProviderStateMixin {
  // Thumbnail quality from Hive
  ThumbnailQuality quality = ThumbnailQuality.low;
  final HiveDataBaseSingleton _dataBaseSingleton =
      HiveDataBaseSingleton.instance;

  @override
  void initState() {
    super.initState();

    // Load saved thumbnail quality
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final data = _dataBaseSingleton.getData;
      setState(() {
        quality = data.thumbnailQuality;
      });
    });
  }

//for large screen devices
  void _showOverlay(BuildContext context) {
    overlayEntry = OverlayEntry(
      builder: (context) => OverlaySongPlayer(
        key: overlayPlayerKey,
        route: SongMiniPlayerRoute.songRoute,
        songData: widget.songData,
        songIndex: widget.songIndex,
        quality: quality,
        onClose: () {
          overlayEntry?.remove();
          overlayEntry = null;
        },
      ),
    );

    Overlay.of(context).insert(overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    bool isSmallScreen = screenWidth < 451;

    return Container(
      margin: EdgeInsets.all(screenSize * 0.00395),
      child: ListTile(
        contentPadding: EdgeInsets.only(
          left: screenWidth * 0.0105,
          right: isSmallScreen ? screenWidth * 0.025 : 1,
          top: isSmallScreen ? 0 : screenSize * 0.0120,
          bottom: isSmallScreen ? 0 : screenSize * 0.0120,
        ),
        splashColor: Colors.transparent,
        onLongPress: () {
          if (isSmallScreen) {
            showBottomOptionSheet(
              context: context,
              songData: widget.songData,
              screenSize: screenSize,
              showDelete: widget.showDelete,
              tabRouteENUM: widget.tabRouteENUM,
              playlistName: widget.playlistName,
            );
            // showLongPressOptions(
            //   context: context,
            //   songData: widget.songData,
            //   screenSize: screenSize,
            //   showDelete: widget.showDelete,
            //   tabRouteENUM: widget.tabRouteENUM,
            //   playlistName: widget.playlistName,
            // );
          }
        },
        onTap: () {
          if (isSmallScreen) {
            // Navigator.of(context)
            //     .pushNamed(AudioPlayerScreen.routeName, arguments: {
            //   "songindex": widget.songIndex,
            //   "songdata": widget.songData,
            //   "route": SongMiniPlayerRoute.songRoute,
            //   "quality": quality,
            //   "tabroute": widget.tabRouteENUM,
            // });

            Navigator.of(context).push(
              slideTransitionRoute(
                context: context,
                songData: widget.songData,
                route: SongMiniPlayerRoute.songRoute,
                quality: quality,
              ),
            );
          } else {
            _showOverlay(context);
          }
        },
        leading: Container(
          width: screenSize * 0.0755,
          height: screenSize * 0.0733,
          margin: EdgeInsets.only(
            left: isSmallScreen ? screenWidth * 0.025 : screenWidth * 0.0039375,
            right: !isSmallScreen ? screenWidth * 0.004 : 0,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(screenSize * 0.0106),
            child: Transform.scale(
              scaleX: quality == ThumbnailQuality.low ? 1 : 1.10,
              child: cacheImage(
                imageUrl: widget.songData.thumbnail,
                width: screenSize * 0.0755,
                height: screenSize * 0.0733,
                islocal: widget.songData.isLocal,
              ),
            ),
          ),
        ),
        title: Padding(
          padding:
              EdgeInsets.only(right: isSmallScreen ? screenWidth * 0.025 : 0),
          child: animatedText(
            text: widget.songData.songName,
            style: Theme.of(context).textTheme.titleSmall!,
          ),
        ),
        subtitle: Padding(
          padding:
              EdgeInsets.only(right: isSmallScreen ? screenWidth * 0.025 : 0),
          child: animatedText(
            text: widget.songData.artist.name,
            style: Theme.of(context).textTheme.bodySmall!,
          ),
        ),
        trailing: isSmallScreen
            ? widget.songData.duration.isNotEmpty
                ? Text(widget.songData.duration)
                : null
            : IconButton(
                onPressed: () {
                  showLongPressOptions(
                    context: context,
                    songData: widget.songData,
                    screenSize: screenSize,
                    showDelete: widget.showDelete,
                    tabRouteENUM: widget.tabRouteENUM,
                    playlistName: widget.playlistName,
                  );
                },
                icon: const Icon(Icons.more_vert),
              ),
      ),
    );
  }
}
