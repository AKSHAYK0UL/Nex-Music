import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/artist_bloc/bloc/artist_bloc.dart';
import 'package:nex_music/bloc/searchedplaylist_bloc/bloc/searchedplaylist_bloc.dart'
    as pl;
import 'package:nex_music/bloc/song_bloc/bloc/song_bloc.dart';
import 'package:nex_music/bloc/video_bloc/bloc/video_bloc.dart';
import 'package:nex_music/core/theme/hexcolor.dart';

class SuggestionTitle extends StatelessWidget {
  final String text;
  final double size;
  const SuggestionTitle({
    super.key,
    required this.text,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<SongBloc>().add(SeachInSongEvent(inputText: text));

        //reset the state
        context.read<VideoBloc>().add(SetStateToInitialEvent());

        //reset the state
        context
            .read<pl.SearchedplaylistBloc>()
            .add(pl.SetStateToInitialEvent());
        //reset the state
        context.read<ArtistBloc>().add(SetStateToinitialEvent());
      },
      child: Container(
        margin: EdgeInsets.only(top: size * 0.00329),
        child: ListTile(
          tileColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          leading: Icon(
            Icons.restore,
            size: size * 0.0380,
          ),
          title: Text(
            text,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          trailing: Icon(
            Icons.trending_up,
            size: size * 0.0350,
          ),
        ),
      ),
    );
  }
}
