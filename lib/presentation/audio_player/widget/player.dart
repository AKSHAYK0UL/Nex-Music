// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/core/theme/hexcolor.dart';

class Player extends StatefulWidget {
  final String songId;
  final double screenSize;
  const Player({
    super.key,
    required this.songId,
    required this.screenSize,
  });

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  final _audioPlayer = AudioPlayer();
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    context
        .read<SongstreamBloc>()
        .add(GetSongStreamUrlEvent(songUrl: widget.songId));
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
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
      listener: (context, state) {
        if (state is StreamSongUrlState) {
          _audioPlayer.setUrl(state.songurl.toString()).then((_) {
            _audioPlayer.play();
          }).catchError((_) {
            setState(() {
              _isPlaying = false;
            });
            debugPrint("error");
          });
        }
      },
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        if (state is LoadingState) {
          return Center(
            child: CircleAvatar(
              backgroundColor: accentColor,
              radius: widget.screenSize * 0.0593,
              child: CircularProgressIndicator(
                color: secondaryColor,
                strokeWidth: 6,
              ),
            ),
          );
        }
        if (state is ErrorState) {
          return Center(
            child: Text(state.errorMessage),
          );
        }
        return Center(
          child: GestureDetector(
            onTap: _togglePlayPause,
            child: CircleAvatar(
              backgroundColor: accentColor,
              radius: widget.screenSize * 0.0593,
              child: Center(
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
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
