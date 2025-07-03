import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/full_artist_songs_bloc/bloc/full_artist_bloc.dart';

import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/core/ui_component/animatedtext.dart';
import 'package:nex_music/model/artistmodel.dart';
import 'package:nex_music/presentation/audio_player/widget/miniplayer.dart';
import 'package:nex_music/presentation/home/artist/artist_album.dart';
import 'package:nex_music/presentation/home/artist/artist_playlist.dart';
import 'package:nex_music/presentation/home/artist/artist_songs.dart';
import 'package:nex_music/presentation/home/artist/artist_videos.dart';

class ArtistFullScreen extends StatefulWidget {
  final ArtistModel artist;
  const ArtistFullScreen({required this.artist, super.key});

  @override
  State<ArtistFullScreen> createState() => _ArtistFullScreenState();
}

class _ArtistFullScreenState extends State<ArtistFullScreen> {
  @override
  void initState() {
    context
        .read<FullArtistSongBloc>()
        .add(GetArtistSongsEvent(artistId: widget.artist.artist.artistId!));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;

    return DefaultTabController(
      initialIndex: 0,
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: animatedText(
            text: widget.artist.artist.name,
            style: Theme.of(context).textTheme.titleLarge!,
          ),
          bottom: ButtonsTabBar(
            splashColor: backgroundColor,
            // backgroundColor: Colors.white24,
            backgroundColor: Colors.blueGrey.shade600,
            unselectedBackgroundColor: secondaryColor,
            width: screenSize / 8.15,
            contentCenter: true,
            elevation: 0,
            labelStyle: Theme.of(context).textTheme.titleSmall,
            unselectedLabelStyle: Theme.of(context).textTheme.bodySmall,
            tabs: const [
              Tab(text: "Songs"),
              Tab(text: "Videos"),
              Tab(text: "Albums"),
              Tab(text: "Playlists"),
            ],
          ),
        ),
        body: TabBarView(children: [
          ArtistSongs(artist: widget.artist),
          ArtistVideos(artist: widget.artist),
          ArtistAlbum(artist: widget.artist),
          ArtistPlaylist(artist: widget.artist)
        ]),
        bottomNavigationBar: MiniPlayer(screenSize: screenSize),
      ),
    );
  }
}
