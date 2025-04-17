import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/enum/song_miniplayer_route.dart';
import 'package:nex_music/enum/quality.dart';
import 'package:nex_music/presentation/audio_player/widget/desktop_audio_player.dart';

class OverlaySongPlayer extends StatefulWidget {
  final Songmodel songData;
  final int songIndex;
  final ThumbnailQuality quality;
  final VoidCallback onClose;
  final SongMiniPlayerRoute route;

  const OverlaySongPlayer({
    super.key,
    required this.songData,
    required this.songIndex,
    required this.quality,
    required this.onClose,
    required this.route,
  });

  @override
  State<OverlaySongPlayer> createState() => OverlaySongPlayerState();
}

class OverlaySongPlayerState extends State<OverlaySongPlayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));

    _animController.forward();
  }

  void closeOverlay() async {
    await _animController.reverse();
    widget.onClose();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Positioned(
      bottom: 0,
      left: (screenWidth - 950) / 2,
      width: 1255,
      height: 800,
      child: SlideTransition(
        position: _slideAnim,
        child: Material(
          elevation: 0,
          shape: RoundedRectangleBorder(side: BorderSide(color: accentColor)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 80, vertical: 30),
                child: IconButton(
                  onPressed: () {
                    closeOverlay();
                  },
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: textColor,
                    size: screenSize * 0.0493,
                  ),
                ),
              ),
              DesktopAudioPlayer(
                songData: widget.songData,
                route: widget.route,
                songIndex: widget.songIndex,
                quality: widget.quality,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
