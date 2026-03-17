import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/artist_bloc/bloc/artist_bloc.dart';
import 'package:nex_music/bloc/full_artist_album_bloc/bloc/fullartistalbum_bloc.dart';
import 'package:nex_music/bloc/search_album_bloc/bloc/search_album_bloc.dart';
import 'package:nex_music/bloc/search_bloc/bloc/search_bloc.dart';
import 'package:nex_music/bloc/searchedplaylist_bloc/bloc/searchedplaylist_bloc.dart'
    as pl;
import 'package:nex_music/bloc/video_bloc/bloc/video_bloc.dart';

class RecentSearchTitle extends StatelessWidget {
  final String text;
  final double size;
  final void Function(String) onSuggestionSelected;

  const RecentSearchTitle({
    super.key,
    required this.text,
    required this.size,
    required this.onSuggestionSelected,
  });

  void _showDeleteDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Search History'),
        content: Text(
            'Are you sure you want to delete "$text" from your search history?'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: false,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              context
                  .read<SearchBloc>()
                  .add(DeleteRecentSearchEvent(search: text));
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Just call the callback, don't trigger search event here
        onSuggestionSelected(text);
        
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
        //reset the state
        context
            .read<FullArtistAlbumBloc>()
            .add(SetFullartistalbumInitialEvent());
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
                  CupertinoIcons.clock,
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
                      // Delete button
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: IconButton(
                          onPressed: () => _showDeleteDialog(context),
                          icon: Icon(
                            CupertinoIcons.delete,
                            color: Colors.red.withValues(alpha: 0.8),
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
