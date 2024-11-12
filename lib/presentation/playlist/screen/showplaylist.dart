import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:nex_music/bloc/playlist_bloc/playlist_bloc.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart' as ss;
import 'package:nex_music/core/ui_component/animatedtext.dart';
import 'package:nex_music/core/ui_component/cacheimage.dart';
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
        context.read<ss.SongstreamBloc>().add(ss.CleanPlaylistEvent());
        final playlistData =
            ModalRoute.of(context)?.settings.arguments as PlayListmodel;

        context
            .read<PlaylistBloc>()
            .add(GetPlaylistEvent(playlistId: playlistData.playListId));
      },
    );
    scrollController.addListener(
      () {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 50) {
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
      buildWhen: (previous, current) {
        if (previous != current) {
          if (current is PlaylistDataState) {
            context
                .read<ss.SongstreamBloc>()
                .add(ss.GetSongPlaylistEvent(songlist: current.playlistSongs));
          }

          //auto load data after every 89 sec
          Future.delayed(const Duration(seconds: 89), () {
            if (!context.mounted) return;
            context
                .read<PlaylistBloc>()
                .add(LoadMoreSongsEvent(playlistId: playlistData.playListId));
          });
        }
        return previous != current;
      },
      builder: (context, playlistState) {
        if (playlistState is LoadingState) {
          return const Loading();
        }

        if (playlistState is ErrorState) {
          return Center(
            child: Text(
              playlistState.errorMessage,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        if (playlistState is PlaylistDataState) {
          return Scaffold(
            appBar: AppBar(
              title: animatedText(
                text: playlistData.playlistName,
                style: Theme.of(context).textTheme.titleLarge!,
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
            body: BlocBuilder<ss.SongstreamBloc, ss.SongstreamState>(
              builder: (context, songState) {
                double bottomPadding = (songState is ss.PausedState ||
                        songState is ss.PlayingState)
                    ? screenSize * 0.1
                    : 0.0;

                return Padding(
                  padding: EdgeInsets.only(
                    left: screenSize * 0.0105,
                    right: screenSize * 0.0105,
                    bottom: bottomPadding,
                  ),
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
                              height: screenSize * 0.280,
                              width: screenSize * 0.280,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(screenSize * 0.0131),
                              ),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(screenSize * 0.0131),
                                child: cacheImage(
                                  imageUrl: playlistData.thumbnail,
                                  width: screenSize * 0.280,
                                  height: screenSize * 0.280,
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                ChipWidget(
                                  label: playlistState.totalSongs
                                      .toString()
                                      .padLeft(10, ' '),
                                  icon: Icons.music_note,
                                  onTap: () {},
                                ),
                                ChipWidget(
                                  label: playlistState.playlistDuration,
                                  icon: Icons.alarm,
                                  onTap: () {},
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
                        itemCount: playlistState.isLoading
                            ? playlistState.playlistSongs.length + 1
                            : playlistState.playlistSongs.length,
                        itemBuilder: (context, index) {
                          if (index < playlistState.playlistSongs.length) {
                            final songData = playlistState.playlistSongs[index];
                            return SongTitle(
                                songData: songData, songIndex: index);
                          } else {
                            return Transform.scale(
                              scaleX: screenSize * 0.00227,
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
                );
              },
            ),
            bottomSheet: MiniPlayer(screenSize: screenSize),
          );
        }

        return const SizedBox();
      },
    );
  }
}
