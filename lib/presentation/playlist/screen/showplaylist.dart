import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/playlist_bloc/playlist_bloc.dart';
import 'package:nex_music/core/ui_component/loading.dart';
import 'package:nex_music/model/playlistmodel.dart';
import 'package:nex_music/presentation/home/widget/song_title.dart';

class ShowPlaylist extends StatefulWidget {
  static const routeName = "/showplaylist";
  const ShowPlaylist({super.key});

  @override
  State<ShowPlaylist> createState() => _ShowPlaylistState();
}

class _ShowPlaylistState extends State<ShowPlaylist> {
  String playlistId = "";
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final playlistData =
          ModalRoute.of(context)?.settings.arguments as PlayListmodel;

      context
          .read<PlaylistBloc>()
          .add(GetPlaylistEvent(playlistId: playlistData.playListId));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final playlistData =
        ModalRoute.of(context)?.settings.arguments as PlayListmodel;

    return BlocBuilder<PlaylistBloc, PlaylistState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        if (state is LoadingState) {
          return const Loading();
        }

        if (state is ErrorState) {
          return Center(
            child: Text(
              state.errorMessage,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }
        if (state is PlaylistDataState) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                playlistData.playlistName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                )
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 220,
                            decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(10)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                playlistData.thumbnail,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Column(
                            children: [
                              SizedBox(
                                width: 125,
                                child: Chip(
                                  label: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Songs: "),
                                      Text("${state.playlistSongs.length} "),
                                      const Icon(
                                        Icons.music_note,
                                        size: 24,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              const SizedBox(
                                width: 125,
                                child: Chip(
                                  label: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Share   "),
                                      Icon(
                                        Icons.share,
                                        size: 25,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              const SizedBox(
                                width: 125,
                                child: Chip(
                                  label: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Shuffle  "),
                                      Icon(
                                        Icons.shuffle,
                                        size: 24,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: state.playlistSongs.length,
                      itemBuilder: (context, index) {
                        if (index < state.playlistSongs.length) {
                          final songData = state.playlistSongs[index];
                          return SongTitle(songData: songData);
                        } else {
                          return const Loading();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
