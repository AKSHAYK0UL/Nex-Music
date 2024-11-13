import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/search_bloc/bloc/search_bloc.dart';
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/core/ui_component/search_bar.dart';
import 'package:nex_music/presentation/audio_player/widget/miniplayer.dart';
import 'package:nex_music/presentation/home/widget/song_title.dart';
import 'package:nex_music/presentation/home/widget/suggestion_title.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = "/searchscreen";

  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Search",
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SearchField(
            onTextChanges: (text) {
              context
                  .read<SearchBloc>()
                  .add(SearchSongSuggestionEvent(inputQuery: text));
            },
            hintText: "Search Song",
          ),
          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              buildWhen: (previous, current) => previous != current,
              builder: (context, state) {
                if (state is LoadingState) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: accentColor,
                    ),
                  );
                }
                if (state is ErrorState) {
                  return Center(child: Text(state.errorMessage));
                }
                if (state is SearchedSongsState) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenSize * 0.0105,
                        vertical: screenSize * 0.0200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.searchedSongs.length,
                      itemBuilder: (context, index) {
                        final songData = state.searchedSongs[index];
                        return SongTitle(songData: songData, songIndex: index);
                      },
                    ),
                  );
                }

                if (state is SearchSuggestionResultState) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenSize * 0.0105,
                        vertical: screenSize * 0.0200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.searchSuggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = state.searchSuggestions[index];
                        return SuggestionTitle(
                          text: suggestion,
                          size: screenSize,
                        );
                      },
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: MiniPlayer(
        screenSize: screenSize,
      ),
    );
  }
}
