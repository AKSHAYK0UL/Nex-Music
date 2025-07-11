import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/artist_bloc/bloc/artist_bloc.dart';
import 'package:nex_music/bloc/searchedplaylist_bloc/bloc/searchedplaylist_bloc.dart'
    as pl;
import 'package:nex_music/bloc/song_bloc/bloc/song_bloc.dart';
import 'package:nex_music/bloc/video_bloc/bloc/video_bloc.dart';
import 'package:nex_music/core/theme/hexcolor.dart';

class SearchField extends StatefulWidget {
  final InputBorder inputBorder;
  final void Function(String) onTextChanges;
  final String hintText;

  const SearchField({
    super.key,
    required this.onTextChanges,
    required this.hintText,
    required this.inputBorder,
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
    final isSmallScreen = MediaQuery.sizeOf(context).width < 451;
    return Container(
      height: 55, //57
      color: backgroundColor,
      padding: EdgeInsets.symmetric(horizontal: screenSize * 0.0100),
      // padding: EdgeInsets.symmetric(
      //     horizontal: screenSize * 0.0131, vertical: screenSize * 0.00659),
      child: Row(
        spacing: screenSize * 0.0080,
        children: [
          CircleAvatar(
            backgroundColor: secondaryColor,
            radius: 26,
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(
                Icons.arrow_back,
                color: textColor,
                size: 28,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              focusNode: _focusNode,
              decoration: InputDecoration(
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 10),
                ),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controller,
                  builder: (context, value, child) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Visibility(
                            visible: !isSmallScreen,
                            child: SizedBox(
                                height: 35,
                                child: VerticalDivider(
                                    thickness: 2,
                                    indent: 0,
                                    endIndent: 0,
                                    color: _focusNode.hasFocus
                                        ? accentColor
                                        : Colors.grey.shade500)),
                          ),
                          IconButton(
                            //value.text.isEmpty && !FocusScope.of(context).hasFocus
                            // ? null
                            // :
                            onPressed: () {
                              if (_focusNode.hasFocus) {
                                _controller.clear();
                                // FocusScope.of(context).unfocus();
                              }
                            },
                            icon: Icon(
                              Icons.cancel,
                              // color: textColor,
                              color: value.text.isEmpty ||
                                      !FocusScope.of(context).hasFocus
                                  ? Colors.grey.shade500
                                  : textColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                hintText: widget.hintText,
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _focusNode.hasFocus
                          ? textColor
                          : Colors.grey.shade500,
                    ),
                border: widget.inputBorder.copyWith(
                  borderSide: BorderSide(
                    width: 2,
                    color: Colors.grey.shade600,
                  ),
                ),
                enabledBorder: widget.inputBorder.copyWith(
                  borderSide: BorderSide(
                    width: 2,
                    color: Colors.grey.shade600,
                  ),
                ),
                focusedBorder: widget.inputBorder.copyWith(
                  borderSide: BorderSide(
                    width: 2,
                    color: accentColor,
                  ),
                ),
                focusedErrorBorder: widget.inputBorder.copyWith(
                  borderSide: const BorderSide(
                    width: 2,
                    color: Colors.red,
                  ),
                ),
              ),
              autofocus: isSmallScreen,
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
          ),
        ],
      ),
    );
  }
}
