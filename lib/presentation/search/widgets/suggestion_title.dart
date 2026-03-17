import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/artist_bloc/bloc/artist_bloc.dart';
import 'package:nex_music/bloc/search_album_bloc/bloc/search_album_bloc.dart';
import 'package:nex_music/bloc/search_bloc/bloc/search_bloc.dart';
import 'package:nex_music/bloc/searchedplaylist_bloc/bloc/searchedplaylist_bloc.dart'
    as pl;
import 'package:nex_music/bloc/video_bloc/bloc/video_bloc.dart';

class SuggestionTitle extends StatelessWidget {
  final String text;
  final double size;
  final void Function(String)onTap;
  final void Function(String) onSuggestionSelected;

  const SuggestionTitle({
    super.key,
    required this.text,
    required this.size,
    required this.onTap,
    required this.onSuggestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        

        onTap(text);
        //reset the state
        context.read<VideoBloc>().add(SetStateToInitialEvent());

        //reset the state
        context
            .read<SearchAlbumBloc>()
            .add(SetStateToInitialSearchAlbumBlocEvent());

        //reset the state
        context
            .read<pl.SearchedplaylistBloc>()
            .add(pl.SetStateToInitialEvent());

        //reset the state
        context.read<ArtistBloc>().add(SetStateToinitialEvent());
      },
      child: Container(
        color: Colors.white,
        height: 56,
        padding: const EdgeInsets.only(left: 20),
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon Section
              SizedBox(
                width: 30,
                child: Icon(
                  CupertinoIcons.search,
                  color: Colors.red.withValues(alpha: 0.8),
                  size: 26,
                ),
              ),
              const SizedBox(width: 15),
              // Text and Divider Section
              Expanded(
                child: Container(
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFE5E5EA),
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          text,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                            letterSpacing: -0.4,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Chevron icon
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: IconButton(
                          onPressed: () {
                            // Trigger search suggestions for the selected text
                            
                            onSuggestionSelected(text);
                          },
                          icon: const Icon(
                            CupertinoIcons.arrow_up_left,
                            color: Color.fromARGB(255, 190, 190, 194),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
