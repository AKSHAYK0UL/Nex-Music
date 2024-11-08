import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/enum/song_miniplayer_route.dart';
import 'package:nex_music/model/songmodel.dart';

class Player extends StatefulWidget {
  final Songmodel songData;
  final double screenSize;
  final SongMiniPlayerRoute route;

  const Player({
    super.key,
    required this.songData,
    required this.screenSize,
    required this.route,
  });

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  final _audioPlayer = AudioPlayer();

  @override
  void initState() {
    if (widget.route == SongMiniPlayerRoute.songRoute) {
      context.read<SongstreamBloc>().add(GetSongStreamEvent(
            songData: widget.songData,
          ));
    }

    super.initState();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongstreamBloc, SongstreamState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        if (state is LoadingState) {
          return Center(
            child: CircleAvatar(
              backgroundColor: accentColor,
              radius: widget.screenSize * 0.0520,
              child: CircularProgressIndicator(
                color: secondaryColor,
                strokeWidth: 4,
              ),
            ),
          );
        } else if (state is ErrorState) {
          return Center(
            child: Text(state.errorMessage),
          );
        }

        return Center(
          child: GestureDetector(
            onTap: () {
              context.read<SongstreamBloc>().add(PlayPauseEvent());
            },
            child: CircleAvatar(
              backgroundColor: accentColor,
              radius: widget.screenSize * 0.0520,
              child: Center(
                child: Icon(
                  state is PausedState ? Icons.play_arrow : Icons.pause,
                  size: widget.screenSize * 0.0791,
                  color: secondaryColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
