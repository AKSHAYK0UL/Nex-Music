import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/core/ui_component/snackbar.dart';
import 'package:nex_music/enum/song_miniplayer_route.dart';
import 'package:nex_music/model/songmodel.dart';

class Player extends StatefulWidget {
  final Songmodel songData;
  final double screenSize;
  final int songIndex;
  final SongMiniPlayerRoute route;

  const Player({
    super.key,
    required this.songData,
    required this.screenSize,
    required this.route,
    required this.songIndex,
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
            songIndex: widget.songIndex,
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
    return BlocConsumer<SongstreamBloc, SongstreamState>(
      listenWhen: (previous, current) => previous != current,
      buildWhen: (previous, current) => previous != current,
      listener: (context, state) {
        if (state is ErrorState) {
          context.read<SongstreamBloc>().add(PauseEvent());
          showSnackbar(context, state.errorMessage);
        }
      },
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
