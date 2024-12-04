import 'package:app_links/app_links.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:nex_music/bloc/artist_bloc/bloc/artist_bloc.dart';
import 'package:nex_music/bloc/auth_bloc/bloc/auth_bloc.dart';
import 'package:nex_music/bloc/connectivity_bloc/bloc/connectivity_bloc.dart';
import 'package:nex_music/bloc/deep_link_bloc/bloc/deeplink_bloc.dart';
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
    androidNotificationIcon: 'drawable/ic_notification',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final repositoryProviderClassInstance = RepositoryProviderClass(
      firebaseAuthInstance: FirebaseAuth.instance,
      connectivity: Connectivity());

  final applink = AppLinks();
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
            create: (context) => HomesectionBloc(context.read<Repository>()),
          ),
          BlocProvider(
            create: (context) => PlaylistBloc(context.read<Repository>()),
          ),
          BlocProvider(
            create: (context) => SongstreamBloc(
              context.read<Repository>(),
              AudioPlayer(),
              context.read<DbRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => SearchBloc(context.read<Repository>()),
          ),
          BlocProvider(
            create: (context) => SongBloc(context.read<Repository>()),
          ),
          BlocProvider(
            create: (context) => VideoBloc(context.read<Repository>()),
          ),
          BlocProvider(
            create: (context) =>
                SearchedplaylistBloc(context.read<Repository>()),
          ),
          BlocProvider(
            create: (context) => ArtistBloc(context.read<Repository>()),
          ),
          BlocProvider(
            create: (context) => RecentplayedBloc(context.read<DbRepository>()),
          ),
          BlocProvider(
            create: (context) => FullArtistSongBloc(context.read<Repository>()),
          ),
          BlocProvider(
            create: (context) => SongDialogBloc(context.read<DbRepository>()),
          ),
          BlocProvider(
            create: (context) => AuthBloc(context.read<AuthRepository>()),
          ),
          BlocProvider(
            create: (context) => UserLoggedBloc(
              repositoryProviderClassInstance.getFirebaseAuthInstance,
            ),
          ),
          BlocProvider(
            create: (context) => DeeplinkBloc(
              context.read<Repository>(),
            ),
          ),
          BlocProvider(
            create: (context) => ConnectivityBloc(
              repositoryProviderClassInstance.getConnectivityInstance,
            ),
          ),
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
                  appLinks: applink,
                  firebaseAuth:
                      repositoryProviderClassInstance.getFirebaseAuthInstance,
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
