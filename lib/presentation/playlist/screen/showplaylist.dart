import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:nex_music/bloc/playlist_bloc/playlist_bloc.dart';
import 'package:nex_music/core/ui_component/loading.dart';
import 'package:nex_music/core/ui_component/snackbar.dart';
import 'package:nex_music/model/playlistmodel.dart';
import 'package:nex_music/presentation/audio_player/widget/miniplayer.dart';
import 'package:nex_music/presentation/home/widget/song_title.dart';
import 'package:nex_music/presentation/playlist/widget/chipwidget.dart';

class ShowPlaylist extends StatefulWidget {
  static const routeName = "/showplaylist";
  const ShowPlaylist({super.key});

  @override
  State<ShowPlaylist> createState() => _ShowPlaylistState();
}

class _ShowPlaylistState extends State<ShowPlaylist> {
  final scrollController = ScrollController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        final playlistData =
            ModalRoute.of(context)?.settings.arguments as PlayListmodel;

        context
            .read<PlaylistBloc>()
            .add(GetPlaylistEvent(playlistId: playlistData.playListId));
      },
    );
    scrollController.addListener(
      () {
        if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
          final playlistData =
              ModalRoute.of(context)?.settings.arguments as PlayListmodel;

          context
              .read<PlaylistBloc>()
              .add(LoadMoreSongsEvent(playlistId: playlistData.playListId));
        }
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playlistData =
        ModalRoute.of(context)?.settings.arguments as PlayListmodel;

    final screenSize = MediaQuery.sizeOf(context).height;

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
                ),
              ],
            ),
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenSize * 0.0105),
              child: ListView(
                controller: scrollController,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: screenSize * 0.0105),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: screenSize * 0.290,
                          width: screenSize * 0.290,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(screenSize * 0.0131),
                          ),
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(screenSize * 0.0131),
                            child: CachedNetworkImage(
                              imageUrl: playlistData.thumbnail,
                              placeholder: (_, __) =>
                                  Image.asset("assets/imageplaceholder.png"),
                              errorWidget: (_, __, ___) =>
                                  Image.asset("assets/imageplaceholder.png"),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            ChipWidget(
                              label: "      ${state.totalSongs}",
                              icon: Icons.music_note,
                              onTap: () {},
                            ),
                            ChipWidget(
                              label: state.playlistDuration,
                              icon: Icons.alarm,
                              onTap: () {
                                showSnackbar(context, "not added yet!");
                              },
                            ),
                            ChipWidget(
                              label: "Share",
                              icon: Icons.share,
                              onTap: () {
                                showSnackbar(context, "not added yet!");
                              },
                            ),
                            ChipWidget(
                              label: "Playlist",
                              icon: Icons.add,
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
                    itemCount: state.isLoading
                        ? state.playlistSongs.length + 1
                        : state.playlistSongs.length,
                    itemBuilder: (context, index) {
                      debugPrint(state.playlistSongs.length.toString());
                      if (index < state.playlistSongs.length) {
                        final songData = state.playlistSongs[index];
                        return SongTitle(songData: songData);
                      } else {
                        return Transform.scale(
                          scaleX: screenSize * 0.00225,
                          scaleY: screenSize * 0.00158,
                          child: Center(
                            child: Lottie.asset(
                              reverse: true,
                              fit: BoxFit.fill,
                              "assets/loadingmore.json",
                              width: double.infinity,
                              height: screenSize * 0.0197,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            //  bottomNavigationBar: //,
            bottomSheet: MiniPlayer(screenSize: screenSize),
          );
        }

        return const SizedBox();
      },
    );
  }
}
