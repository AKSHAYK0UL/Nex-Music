import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/full_artist_album_bloc/bloc/fullartistalbum_bloc.dart';
import 'package:nex_music/bloc/full_artist_playlist_bloc/bloc/full_artist_playlist_bloc.dart';
import 'package:nex_music/bloc/full_artist_songs_bloc/bloc/full_artist_bloc.dart';
import 'package:nex_music/bloc/full_artist_video_bloc/bloc/full_artist_video_bloc_bloc.dart';
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/core/ui_component/animatedtext.dart';
import 'package:nex_music/model/artistmodel.dart';
import 'package:nex_music/presentation/home/artist/artist_album.dart';
import 'package:nex_music/presentation/home/artist/artist_playlist.dart';
import 'package:nex_music/presentation/home/artist/artist_songs.dart';
import 'package:nex_music/presentation/home/artist/artist_videos.dart';

class ArtistFullScreen extends StatefulWidget {
  static const routeName = "/artistfullscreen";
  const ArtistFullScreen({super.key});

  @override
  State<ArtistFullScreen> createState() => _ArtistFullScreenState();
}

class _ArtistFullScreenState extends State<ArtistFullScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final artist = ModalRoute.of(context)?.settings.arguments as ArtistModel;

      context
          .read<FullArtistSongBloc>()
          .add(GetArtistSongsEvent(artistId: artist.artist.artistId!));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;

    final artist = ModalRoute.of(context)?.settings.arguments as ArtistModel;

    return DefaultTabController(
      initialIndex: 0,
      length: 4,
      child: PopScope(
        canPop: true,
        onPopInvokedWithResult: (_, __) {
          context
              .read<FullArtistVideoBloc>()
              .add(SetFullArtistVideoBlocInitialEvent());
          context
              .read<FullArtistAlbumBloc>()
              .add(SetFullartistalbumInitialEvent());
          context
              .read<FullArtistPlaylistBloc>()
              .add(SetFullArtistPlaylistInitialEvent());
        },
        child: Scaffold(
          appBar: AppBar(
            title: animatedText(
                text: artist.artist.name,
                style: Theme.of(context).textTheme.titleLarge!),
            bottom: ButtonsTabBar(
              splashColor: backgroundColor,
              backgroundColor: Colors.white38,
              unselectedBackgroundColor: secondaryColor,
              width: screenSize / 8,
              contentCenter: true,
              elevation: 0,
              labelStyle: Theme.of(context).textTheme.titleSmall,
              unselectedLabelStyle: Theme.of(context).textTheme.bodySmall,
              tabs: const [
                Tab(
                  text: "Songs",
                ),
                Tab(
                  text: "Videos",
                ),
                Tab(
                  text: "Albums",
                ),
                Tab(
                  text: "Playlists",
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              ArtistSongs(
                artist: artist,
              ),
              ArtistVideos(
                artist: artist,
              ),
              ArtistAlbum(
                artist: artist,
              ),
              ArtistPlaylist(
                artist: artist,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
