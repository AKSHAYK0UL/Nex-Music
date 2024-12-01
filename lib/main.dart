import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:nex_music/bloc/artist_bloc/bloc/artist_bloc.dart';
import 'package:nex_music/bloc/auth_bloc/bloc/auth_bloc.dart';
import 'package:nex_music/bloc/full_artist_songs_bloc/bloc/full_artist_bloc.dart';
import 'package:nex_music/bloc/homesection_bloc/homesection_bloc.dart';
import 'package:nex_music/bloc/playlist_bloc/playlist_bloc.dart';
import 'package:nex_music/bloc/recent_played_bloc/bloc/recentplayed_bloc.dart';
import 'package:nex_music/bloc/search_bloc/bloc/search_bloc.dart';
import 'package:nex_music/bloc/searchedplaylist_bloc/bloc/searchedplaylist_bloc.dart';
import 'package:nex_music/bloc/song_bloc/bloc/song_bloc.dart';
import 'package:nex_music/bloc/song_dialog_bloc/bloc/song_dialog_bloc.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/bloc/user_logged_bloc/bloc/user_logged_bloc.dart';
import 'package:nex_music/bloc/video_bloc/bloc/video_bloc.dart';
import 'package:nex_music/core/bloc_provider/repository_provider/repository_provider.dart';
import 'package:nex_music/core/route/route.dart';
import 'package:nex_music/core/theme/theme.dart';
import 'package:nex_music/presentation/auth/screens/auth_screen.dart';
import 'package:nex_music/presentation/home/navbar/navbar.dart';
import 'package:nex_music/repository/auth_repository/auth_repository.dart';
import 'package:nex_music/repository/db_repository/db_repository.dart';
import 'package:nex_music/repository/home_repo/repository.dart';

import 'package:nex_music/secrets/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  final repositoryProviderClass =
      RepositoryProviderClass(firebaseAuthInstance: FirebaseAuth.instance);
  runApp(MyApp(repositoryProviderClass));
}

class MyApp extends StatelessWidget {
  final RepositoryProviderClass repositoryProviderClassInstance;
  const MyApp(this.repositoryProviderClassInstance, {super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        repositoryProviderClassInstance.authRepositoryProvider,
        repositoryProviderClassInstance.repositoryProvider,
        repositoryProviderClassInstance.dbRepositoryProvider,
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (contexts) => HomesectionBloc(contexts.read<Repository>()),
          ),
          BlocProvider(
            create: (contexts) => PlaylistBloc(contexts.read<Repository>()),
          ),
          BlocProvider(
            create: (contexts) => SongstreamBloc(
              contexts.read<Repository>(),
              AudioPlayer(),
              contexts.read<DbRepository>(),
            ),
          ),
          BlocProvider(
            create: (contexts) => SearchBloc(contexts.read<Repository>()),
          ),
          BlocProvider(
            create: (contexts) => SongBloc(contexts.read<Repository>()),
          ),
          BlocProvider(
            create: (contexts) => VideoBloc(contexts.read<Repository>()),
          ),
          BlocProvider(
            create: (contexts) =>
                SearchedplaylistBloc(contexts.read<Repository>()),
          ),
          BlocProvider(
            create: (contexts) => ArtistBloc(contexts.read<Repository>()),
          ),
          BlocProvider(
            create: (contexts) =>
                RecentplayedBloc(contexts.read<DbRepository>()),
          ),
          BlocProvider(
            create: (contexts) =>
                FullArtistSongBloc(contexts.read<Repository>()),
          ),
          BlocProvider(
            create: (contexts) => SongDialogBloc(contexts.read<DbRepository>()),
          ),
          BlocProvider(
            create: (context) => AuthBloc(context.read<AuthRepository>()),
          ),
          BlocProvider(
            create: (context) => UserLoggedBloc(
              repositoryProviderClassInstance.getFirebaseAuthInstance,
            ),
          )
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'NEX MUSIC',
          theme: themeData(context),
          home: BlocSelector<UserLoggedBloc, UserLoggedState, bool>(
            selector: (state) {
              return state is LoggedInState;
            },
            builder: (context, isloggedIn) {
              if (isloggedIn) {
                // Display when the user is logged in
                return NavBar(
                  repositoryProviderClassInstance:
                      repositoryProviderClassInstance,
                );
              } else {
                return const AuthScreen(); // Display when the user is logged out
              }
            },
          ),
          routes: routes,
        ),
      ),
    );
  }
}
