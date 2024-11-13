import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/search_bloc/bloc/search_bloc.dart';
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
        context.read<SearchBloc>().add(SeachSongEvent(inputText: text));
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
