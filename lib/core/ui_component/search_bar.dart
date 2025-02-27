import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/artist_bloc/bloc/artist_bloc.dart';
import 'package:nex_music/bloc/searchedplaylist_bloc/bloc/searchedplaylist_bloc.dart'
    as pl;
import 'package:nex_music/bloc/song_bloc/bloc/song_bloc.dart';
import 'package:nex_music/bloc/video_bloc/bloc/video_bloc.dart';
import 'package:nex_music/core/theme/hexcolor.dart';

class SearchField extends StatefulWidget {
  final void Function(String) onTextChanges;
  final String hintText;

  const SearchField({
    super.key,
    required this.onTextChanges,
    required this.hintText,
  });

  @override
  State<SearchField> createState() => SearchFieldState();
}

class SearchFieldState extends State<SearchField> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();

  void setText(String text) {
    _controller.text = text;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
    _controller.addListener(() {
      widget.onTextChanges(_controller.text.trim());
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;

    return Container(
      color: backgroundColor,
      padding: EdgeInsets.symmetric(
          horizontal: screenSize * 0.0131, vertical: screenSize * 0.00659),
      child: TextField(
        focusNode: _focusNode,
        decoration: InputDecoration(
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, child) => IconButton(
              onPressed: value.text.isEmpty
                  ? null
                  : () {
                      _controller.clear();
                    },
              icon: Icon(
                Icons.cancel,
                color: value.text.isEmpty ? Colors.grey.shade500 : textColor,
              ),
            ),
          ),
          hintText: widget.hintText,
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _focusNode.hasFocus ? textColor : Colors.grey.shade500,
              ),
          border: UnderlineInputBorder(
            borderSide: BorderSide(
              width: 2,
              color: secondaryColor,
            ),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              width: 2,
              color: secondaryColor,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              width: 2,
              color: textColor,
            ),
          ),
          focusedErrorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              width: 2,
              color: Colors.red,
            ),
          ),
        ),
        autofocus: true,
        cursorColor: textColor,
        cursorHeight: screenSize * 0.0329,
        style: Theme.of(context).textTheme.bodyMedium,
        controller: _controller,
        textInputAction: TextInputAction.search,
        onSubmitted: (value) {
          context
              .read<SongBloc>()
              .add(SeachInSongEvent(inputText: _controller.text.trim()));
          //reset the state
          context.read<VideoBloc>().add(SetStateToInitialEvent());

          //reset the state
          context
              .read<pl.SearchedplaylistBloc>()
              .add(pl.SetStateToInitialEvent());
          //reset the state
          context.read<ArtistBloc>().add(SetStateToinitialEvent());
        },
      ),
    );
  }
}
