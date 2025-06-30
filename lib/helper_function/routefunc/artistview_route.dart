import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/full_artist_album_bloc/bloc/fullartistalbum_bloc.dart';
import 'package:nex_music/bloc/full_artist_playlist_bloc/bloc/full_artist_playlist_bloc.dart';
import 'package:nex_music/bloc/full_artist_songs_bloc/bloc/full_artist_bloc.dart';
import 'package:nex_music/bloc/full_artist_video_bloc/bloc/full_artist_video_bloc_bloc.dart';
import 'package:nex_music/core/bloc_provider/repository_provider/repository_provider.dart';
import 'package:nex_music/model/artistmodel.dart';
import 'package:nex_music/presentation/home/artist/artist_full.dart';
import 'package:nex_music/repository/home_repo/repository.dart';

void artistViewRoute(BuildContext context, ArtistModel artist) {
  final repositoryProviderClassInstance = RepositoryProviderClass(
      firebaseAuthInstance: FirebaseAuth.instance,
      firebaseFirestore: FirebaseFirestore.instance,
      connectivity: Connectivity());

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => RepositoryProvider(
        create: (context) => repositoryProviderClassInstance.repositoryProvider,
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) =>
                  FullArtistSongBloc(context.read<Repository>()),
            ),
            BlocProvider(
              create: (context) =>
                  FullArtistVideoBloc(context.read<Repository>()),
            ),
            BlocProvider(
              create: (context) =>
                  FullArtistAlbumBloc(context.read<Repository>()),
            ),
            BlocProvider(
              create: (context) =>
                  FullArtistPlaylistBloc(context.read<Repository>()),
            ),
          ],
          child: ArtistFullScreen(
            artist: artist,
          ),
        ),
      ),
    ),
  );
}
