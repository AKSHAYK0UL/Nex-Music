import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';

class Player extends StatefulWidget {
  final String songId;
  const Player({super.key, required this.songId});

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
            print("error");
          });
        }
      },
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        if (state is LoadingState) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is ErrorState) {
          return Center(
            child: Text(state.errorMessage),
          );
        }
        return Center(
          child: IconButton(
            onPressed: _togglePlayPause,
            icon: Icon(
              _isPlaying ? Icons.pause_circle : Icons.play_circle,
              size: 100.0,
              color: Colors.blue,
            ),
          ),
        );
      },
    );
  }
}
