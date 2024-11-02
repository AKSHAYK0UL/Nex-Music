import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/playlist_bloc/playlist_bloc.dart';
import 'package:nex_music/core/ui_component/loading.dart';
import 'package:nex_music/core/ui_component/snackbar.dart';
import 'package:nex_music/model/playlistmodel.dart';
import 'package:nex_music/presentation/home/widget/song_title.dart';
import 'package:nex_music/presentation/playlist/widget/chipwidget.dart';

class ShowPlaylist extends StatefulWidget {
  static const routeName = "/showplaylist";
  const ShowPlaylist({super.key});

  @override
  State<ShowPlaylist> createState() => _ShowPlaylistState();
}

class _ShowPlaylistState extends State<ShowPlaylist> {
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
    final screenSize = MediaQuery.sizeOf(context).height;
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
              padding: EdgeInsets.symmetric(horizontal: screenSize * 0.0105),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: screenSize * 0.0105),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: screenSize * 0.0052),
                            height: screenSize * 0.290,
                            width: screenSize * 0.290,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(screenSize * 0.0131)),
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(screenSize * 0.0131),
                              child: CachedNetworkImage(
                                imageUrl: playlistData.thumbnail,
                                placeholder: (_, __) {
                                  return Image.asset(
                                    "assets/imageplaceholder.png",
                                  );
                                },
                                errorWidget: (_, __, ___) =>
                                    Image.asset("assets/imageplaceholder.png"),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: screenSize * 0.0263,
                          ),
                          Column(
                            children: [
                              ChipWidget(
                                label: state.playlistSongs.length.toString(),
                                icon: Icons.music_note,
                                onTap: () {
                                  showSnackbar(context, "not added yet!");
                                },
                              ),
                              SizedBox(
                                height: screenSize * 0.0197,
                              ),
                              ChipWidget(
                                label: "Share",
                                icon: Icons.share,
                                onTap: () {
                                  showSnackbar(context, "not added yet!");
                                },
                              ),
                              SizedBox(
                                height: screenSize * 0.0197,
                              ),
                              ChipWidget(
                                label: "Shuffle",
                                icon: Icons.shuffle,
                                onTap: () {
                                  showSnackbar(context, "not added yet!");
                                },
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
