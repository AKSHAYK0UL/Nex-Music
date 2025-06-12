import 'package:app_links/app_links.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:nex_music/bloc/artist_bloc/bloc/artist_bloc.dart';
import 'package:nex_music/bloc/auth_bloc/bloc/auth_bloc.dart';
import 'package:nex_music/bloc/connectivity_bloc/bloc/connectivity_bloc.dart';
import 'package:nex_music/bloc/deep_link_bloc/bloc/deeplink_bloc.dart';
import 'package:nex_music/bloc/download_bloc/bloc/download_bloc.dart';
import 'package:nex_music/bloc/favorites_bloc/bloc/favorites_bloc.dart';
import 'package:nex_music/bloc/favorites_songs_bloc/bloc/favorites_songs_bloc.dart';
import 'package:nex_music/bloc/full_artist_songs_bloc/bloc/full_artist_bloc.dart';
import 'package:nex_music/bloc/homesection_bloc/homesection_bloc.dart';
import 'package:nex_music/bloc/playlist_bloc/playlist_bloc.dart';
import 'package:nex_music/bloc/quality_bloc/bloc/quality_bloc.dart';
import 'package:nex_music/bloc/recent_played_bloc/bloc/recentplayed_bloc.dart';
import 'package:nex_music/bloc/search_bloc/bloc/search_bloc.dart';
import 'package:nex_music/bloc/searchedplaylist_bloc/bloc/searchedplaylist_bloc.dart';
import 'package:nex_music/bloc/song_bloc/bloc/song_bloc.dart';
import 'package:nex_music/bloc/song_dialog_bloc/bloc/song_dialog_bloc.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/bloc/user_logged_bloc/bloc/user_logged_bloc.dart';
import 'package:nex_music/bloc/user_playlist_bloc/bloc/user_playlist_bloc.dart';
import 'package:nex_music/bloc/user_playlist_songs_bloc/bloc/user_playlist_song_bloc.dart';
import 'package:nex_music/bloc/video_bloc/bloc/video_bloc.dart';
import 'package:nex_music/constants/const.dart';
import 'package:nex_music/core/bloc_provider/repository_provider/repository_provider.dart';
import 'package:nex_music/core/route/route.dart';
import 'package:nex_music/core/services/hive/hive__adapter_model/hive_quality_class.dart';
import 'package:nex_music/core/services/hive/hive__adapter_model/hive_registrar.g.dart';
import 'package:nex_music/core/services/hive_singleton.dart';
import 'package:nex_music/core/theme/theme.dart';
import 'package:nex_music/helper_function/storage_permission/storage_permission.dart';
import 'package:nex_music/network_provider/home_data/download_provider.dart';
import 'package:nex_music/presentation/auth/screens/auth_screen.dart';
import 'package:nex_music/presentation/home/navbar/screen/navbar.dart';
import 'package:nex_music/repository/auth_repository/auth_repository.dart';
import 'package:nex_music/repository/db_repository/db_repository.dart';
import 'package:nex_music/repository/downlaod_repository/download_repository.dart';
import 'package:nex_music/repository/home_repo/repository.dart';

import 'package:nex_music/secrets/firebase_options.dart';
import 'package:nex_music/utils/audioutils/audio_handler.dart';
import 'package:path_provider/path_provider.dart';

final audioPlayer = AudioPlayer(); //global audioplayer  instance
OverlayEntry? overlayEntry;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Hive.initFlutter();
  // Hive.registerAdapter(HiveQualityAdapter());
  JustAudioMediaKit.bufferSize = 8 * 1024 * 1024; // 8 MB
  JustAudioMediaKit.title = 'Nex Music';
  JustAudioMediaKit.protocolWhitelist = const ['http', 'https'];

  final dir = await getApplicationDocumentsDirectory();
  Hive
    ..init(dir.path)
    ..registerAdapters();

  await Hive.openBox<HiveQuality>(qualitySettingsBox);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandler(audioPlayer),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
      androidNotificationChannelName: 'Audio Playback',
      androidNotificationOngoing: true,
      androidResumeOnClick: true,
      preloadArtwork: true,
      androidNotificationIcon: 'drawable/ic_notification',
    ),
  );
  final dbinstance = HiveDataBaseSingleton.instance;

  //for windows title bar
  // doWhenWindowReady(() {
  //   // final initialSize = Size(800, 600);
  //   // appWindow.minSize = initialSize;
  //   // appWindow.size = initialSize;
  //   appWindow.alignment = Alignment.center;
  //   appWindow.title = "Nex Music";
  //   appWindow.show();
  // });
  runApp(MyApp(
    myAudioHandler: audioHandler,
    dbInstance: dbinstance,
  ));
}

class MyApp extends StatelessWidget {
  final AudioPlayerHandler myAudioHandler;
  final HiveDataBaseSingleton dbInstance;
  MyApp({super.key, required this.myAudioHandler, required this.dbInstance});
  final repositoryProviderClassInstance = RepositoryProviderClass(
      firebaseAuthInstance: FirebaseAuth.instance,
      firebaseFirestore: FirebaseFirestore.instance,
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
            create: (context) {
              // Create the SongstreamBloc instance.
              final bloc = SongstreamBloc(
                context.read<Repository>(),
                audioPlayer,
                myAudioHandler,
                context.read<DbRepository>(),
                dbInstance,
              );
              // Immediately pass the bloc instance to the audio handler.
              myAudioHandler.setSongstreamBloc(bloc);
              return bloc;
            },
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
            create: (context) =>
                AuthBloc(context.read<AuthRepository>(), dbInstance),
          ),
          BlocProvider(
            create: (context) => FavoritesBloc(context.read<DbRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                FavoritesSongsBloc(context.read<DbRepository>()),
          ),
          BlocProvider(
              create: (context) =>
                  UserPlaylistBloc(context.read<DbRepository>())),
          BlocProvider(
            create: (context) =>
                UserPlaylistSongBloc(context.read<DbRepository>()),
          ),
          BlocProvider(
            create: (context) => DownloadBloc(
              context.read<Repository>(),
              DownloadRepo(
                DownloadProvider(
                  dio: Dio(),
                ),
              ),
              StoragePermission(DeviceInfoPlugin()),
            ),
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
          BlocProvider(create: (context) => QualityBloc(dbInstance)),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Nex Music',
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
/**
 * 
 *   final audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandler(audioPlayer),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
      androidNotificationChannelName: 'Audio Playback',
      androidNotificationOngoing: true,
      androidResumeOnClick: true,
      preloadArtwork: true,
      androidNotificationIcon: 'drawable/ic_notification',
    ),
  );
 */
