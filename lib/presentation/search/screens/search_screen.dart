import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_music/bloc/search_bloc/bloc/search_bloc.dart';
import 'package:nex_music/bloc/song_bloc/bloc/song_bloc.dart' as songbloc;
import 'package:nex_music/core/route/go_router/go_router.dart';
import 'package:nex_music/presentation/search/widgets/recentsearchtitle.dart';
import 'package:nex_music/presentation/search/widgets/suggestion_title.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = "/searchscreen";
  final String? searchText;

  const SearchScreen({super.key, this.searchText});

  @override
  State<SearchScreen> createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    if (widget.searchText != null && widget.searchText!.isNotEmpty) {
      _searchController.text = widget.searchText!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocusNode.requestFocus();
        _searchController.selection = TextSelection.fromPosition(
          TextPosition(offset: _searchController.text.length),
        );
      });
    }
    super.initState();
  }

  void requestFocus() {
    FocusScope.of(context).requestFocus(_searchFocusNode);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<SearchBloc>().add(LoadRecentSearchEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:  EdgeInsets.only(
                left:context.canPop()? 0.0:16.0,
                right: 16.0,
                bottom: 10.0,
                top: 10.0,
              ),
              child: Row(
                children: [
                  if (context.canPop())
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: () => context.pop(),
                    ),
                  Expanded(
                    child: CupertinoSearchTextField(
                      cursorColor: Colors.red,
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      placeholder: 'Search songs, albums, artists...',
                      onChanged: (text) {
                        if (text.isEmpty) {
                          context
                              .read<SearchBloc>()
                              .add(LoadRecentSearchEvent());
                        } else {
                          context.read<SearchBloc>().add(
                                SearchSongSuggestionEvent(inputQuery: text),
                              );
                        }
                      },
                      onSubmitted: (text) {
                        if (text.isNotEmpty) {
                          _performSearch(text);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                buildWhen: (previous, current) => previous != current,
                builder: (context, state) {
                  if (state is LoadingState) {
                    return Center(
                      child: CupertinoActivityIndicator(
                        color: Colors.red.withValues(alpha: 0.8),
                        radius: 15,
                      ),
                    );
                  }

                  if (state is LoadedRecentSearchState) {
                    return StreamBuilder<List<String>>(
                      stream: state.searchHistoryStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CupertinoActivityIndicator(
                              color: Colors.red.withValues(alpha: 0.8),
                              radius: 15,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              snapshot.error.toString(),
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text(
                              'No recent searches',
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        } else {
                          final recentSearches = snapshot.data!;
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenSize * 0.0105,
                              vertical: screenSize * 0.0200,
                            ),
                            child: ListView.builder(
                              itemCount: recentSearches.length,
                              itemBuilder: (context, index) {
                                final recentSearch = recentSearches[index];
                                return RecentSearchTitle(
                                  text: recentSearch,
                                  size: screenSize,
                                  onSuggestionSelected: (selectedText) {
                                    _searchController.text = selectedText;
                                    _performSearch(selectedText);
                                  },
                                );
                              },
                            ),
                          );
                        }
                      },
                    );
                  }

                  if (state is SearchSuggestionResultState) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenSize * 0.0105,
                        vertical: screenSize * 0.0200,
                      ),
                      child: ListView.builder(
                        itemCount: state.searchSuggestions.length,
                        itemBuilder: (context, index) {
                          final suggestion = state.searchSuggestions[index];
                          return SuggestionTitle(
                            text: suggestion,
                            size: screenSize,
                            onTap: (text) {
                              _searchController.text = text;
                              _performSearch(text);
                            },
                            onSuggestionSelected: (selectedText) {
                              _searchController.text = selectedText;
                            },
                          );
                        },
                      ),
                    );
                  }

                  if (state is ErrorState) {
                    return Center(
                      child: Text(
                        state.errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _performSearch(String query) async {
    if (query.isEmpty) return;

    context.read<SearchBloc>().add(
          AddRecentSearchEvent(search: query),
        );

    context.read<songbloc.SongBloc>().add(
          songbloc.SeachInSongEvent(inputText: query),
        );

    final result = await context.pushNamed(
      RouterName.searchResultName,
      extra: query,
    );

    if (result == true) {
      _searchFocusNode.requestFocus();
    }
  }
}
