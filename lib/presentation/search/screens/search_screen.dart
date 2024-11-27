import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/search_bloc/bloc/search_bloc.dart';
import 'package:nex_music/bloc/song_bloc/bloc/song_bloc.dart' as songbloc;
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/core/ui_component/search_bar.dart';
import 'package:nex_music/presentation/audio_player/widget/miniplayer.dart';
import 'package:nex_music/presentation/search/screens/search_result_tab.dart';
import 'package:nex_music/presentation/search/widgets/recentsearchtitle.dart';
import 'package:nex_music/presentation/search/widgets/suggestion_title.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = "/searchscreen";

  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final _searchFieldKey = GlobalKey<SearchFieldState>();
  // @override
  // void initState() {
  //   context.read<SearchBloc>().add(LoadRecentSearchEvent());

  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;

    return BlocListener<songbloc.SongBloc, songbloc.SongState>(
      listenWhen: (previous, current) => previous != current,
      listener: (context, state) {
        if (state is songbloc.LoadingState) {
          context.read<SearchBloc>().add(AddRecentSearchEvent(
              search: state.query)); //add query to recent search list
          Navigator.of(context).pushNamed(
            SearchResultTab.routeName,
            arguments: state.query,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: SearchField(
            key: _searchFieldKey,
            onTextChanges: (text) {
              if (text.isEmpty) {
                context.read<SearchBloc>().add(LoadRecentSearchEvent());
              } else {
                context
                    .read<SearchBloc>()
                    .add(SearchSongSuggestionEvent(inputQuery: text));
              }
            },
            hintText: "Search songs, albums, artists...",
          ),
        ),
        body: BlocBuilder<SearchBloc, SearchState>(
          buildWhen: (previous, current) => previous != current,
          builder: (context, state) {
            print("Current STATE is $state");
            if (state is LoadingState) {
              return Center(
                child: CircularProgressIndicator(
                  color: accentColor,
                ),
              );
            }
            if (state is LoadedRecentSearchState) {
              return ListView.builder(
                  itemCount: state.recentSerach.length,
                  reverse: true,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final recentSearch = state.recentSerach[index];
                    return RecentSearchTitle(
                      text: recentSearch,
                      size: screenSize,
                      onSuggestionSelected: (selectedText) {
                        _searchFieldKey.currentState?.setText(selectedText);
                      },
                    );
                  });
            }
            if (state is ErrorState) {
              return Center(child: Text(state.errorMessage));
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
                      onSuggestionSelected: (selectedText) {
                        _searchFieldKey.currentState?.setText(selectedText);
                      },
                    );
                  },
                ),
              );
            }
            return const SizedBox();
          },
        ),
        bottomNavigationBar: MiniPlayer(screenSize: screenSize),
      ),
    );
  }
}
