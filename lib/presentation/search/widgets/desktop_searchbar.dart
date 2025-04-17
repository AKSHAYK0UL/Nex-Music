import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/search_bloc/bloc/search_bloc.dart';
import 'package:nex_music/bloc/song_bloc/bloc/song_bloc.dart' as songbloc;
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/core/ui_component/loading_disk.dart';
import 'package:nex_music/core/ui_component/search_bar.dart';
import 'package:nex_music/presentation/search/screens/search_result_tab.dart';
import 'package:nex_music/presentation/search/widgets/recentsearchtitle.dart';
import 'package:nex_music/presentation/search/widgets/suggestion_title.dart';

class DesktopSearchBar extends StatefulWidget {
  const DesktopSearchBar({super.key});

  @override
  State<DesktopSearchBar> createState() => _DesktopSearchBarState();
}

class _DesktopSearchBarState extends State<DesktopSearchBar> {
  final _searchFieldKey = GlobalKey<SearchFieldState>();
  bool _showSuggestions = false;
  bool _showRecent = false;
  int cardContainerItems = 0;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size.height;

    return BlocListener<songbloc.SongBloc, songbloc.SongState>(
      listenWhen: (previous, current) => previous != current,
      listener: (context, state) {
        if (state is songbloc.LoadingState) {
          context
              .read<SearchBloc>()
              .add(AddRecentSearchEvent(search: state.query));
          Navigator.of(context).pushNamed(
            SearchResultTab.routeName,
            arguments: state.query,
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            child: SizedBox(
              width: 700,
              height: 56,
              child: SearchField(
                key: _searchFieldKey,
                inputBorder: buildOutlineInputBorder,
                hintText: "Search songs, albums, artists...",
                onTextChanges: (value) {
                  setState(() {
                    _showSuggestions = value.isNotEmpty;
                  });
                  if (value.isEmpty) {
                    context.read<SearchBloc>().add(LoadRecentSearchEvent());
                  } else {
                    context
                        .read<SearchBloc>()
                        .add(SearchSongSuggestionEvent(inputQuery: value));
                  }
                },
              ),
            ),
          ),
          // Suggestion / recent search container
          Visibility(
            visible: (_showSuggestions || _showRecent) &&
                FocusScope.of(context).hasFocus,
            child: Card(
              borderOnForeground: false,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 2,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 650,
                height: cardContainerItems * 58 < 600
                    ? cardContainerItems * 58
                    : 600,
                decoration: BoxDecoration(
                    color: secondaryColor,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: accentColor)),
                child: BlocBuilder<SearchBloc, SearchState>(
                  buildWhen: (previous, current) => previous != current,
                  builder: (context, state) {
                    if (state is LoadingState) {
                      return loadingDisk();
                    }
                    if (state is LoadedRecentSearchState) {
                      _showRecent = state.recentSerach.isNotEmpty;
                      cardContainerItems = state.recentSerach.length;
                      return ListView.builder(
                        itemCount: state.recentSerach.length,
                        itemBuilder: (context, index) {
                          final rIndex = state.recentSerach.length - index - 1;
                          final recentSearch = state.recentSerach[rIndex];
                          return GestureDetector(
                            onTap: () {
                              _searchFieldKey.currentState
                                  ?.setText(recentSearch);
                              setState(() {
                                _showSuggestions = false;
                              });
                            },
                            child: RecentSearchTitle(
                              text: recentSearch,
                              size: screenSize,
                              onSuggestionSelected: (selectedText) {
                                _searchFieldKey.currentState
                                    ?.setText(selectedText);
                                setState(() {
                                  _showSuggestions = false;
                                });
                              },
                            ),
                          );
                        },
                      );
                    }
                    if (state is ErrorState) {
                      return Center(child: Text(state.errorMessage));
                    }
                    if (state is SearchSuggestionResultState) {
                      cardContainerItems = state.searchSuggestions.length;
                      return ListView.builder(
                        itemCount: state.searchSuggestions.length,
                        itemBuilder: (context, index) {
                          final suggestion = state.searchSuggestions[index];
                          return GestureDetector(
                            onTap: () {
                              _searchFieldKey.currentState?.setText(suggestion);
                              setState(() {
                                _showSuggestions = false;
                              });
                            },
                            child: SuggestionTitle(
                              text: suggestion,
                              size: screenSize,
                              onSuggestionSelected: (selectedText) {
                                _searchFieldKey.currentState
                                    ?.setText(selectedText);
                                setState(() {
                                  _showSuggestions = false;
                                });
                              },
                            ),
                          );
                        },
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

OutlineInputBorder get buildOutlineInputBorder {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(25),
    borderSide: BorderSide(color: accentColor, width: 2),
  );
}
