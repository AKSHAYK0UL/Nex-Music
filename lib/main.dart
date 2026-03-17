import 'package:app_links/app_links.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:nex_music/bloc/full_artist_album_bloc/bloc/fullartistalbum_bloc.dart';
import 'package:nex_music/bloc/full_artist_playlist_bloc/bloc/full_artist_playlist_bloc.dart';
import 'package:nex_music/bloc/full_artist_songs_bloc/bloc/full_artist_bloc.dart';
import 'package:nex_music/bloc/full_artist_video_bloc/bloc/full_artist_video_bloc_bloc.dart';
import 'package:nex_music/bloc/homesection_bloc/homesection_bloc.dart';
import 'package:nex_music/bloc/offline_songs_bloc/bloc/offline_songs_bloc.dart';
import 'package:nex_music/bloc/playlist_bloc/playlist_bloc.dart';
import 'package:nex_music/bloc/quality_bloc/bloc/quality_bloc.dart';
import 'package:nex_music/bloc/recent_played_bloc/bloc/recentplayed_bloc.dart';
import 'package:nex_music/bloc/saved_artists_bloc/bloc/saved_artists_bloc.dart';
import 'package:nex_music/bloc/search_album_bloc/bloc/search_album_bloc.dart';
import 'package:nex_music/bloc/search_bloc/bloc/search_bloc.dart';
import 'package:nex_music/bloc/searchedplaylist_bloc/bloc/searchedplaylist_bloc.dart';
import 'package:nex_music/bloc/sleep_timer_bloc/bloc/sleep_timer_bloc.dart';
import 'package:nex_music/bloc/song_bloc/bloc/song_bloc.dart';
import 'package:nex_music/bloc/song_dialog_bloc/bloc/song_dialog_bloc.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/bloc/upnext_bloc/upnext_bloc.dart';
import 'package:nex_music/bloc/user_logged_bloc/bloc/user_logged_bloc.dart';
import 'package:nex_music/bloc/user_playlist_bloc/bloc/user_playlist_bloc.dart';
import 'package:nex_music/bloc/user_playlist_songs_bloc/bloc/user_playlist_song_bloc.dart';
import 'package:nex_music/bloc/video_bloc/bloc/video_bloc.dart';
import 'package:nex_music/constants/const.dart';
import 'package:nex_music/core/bloc_provider/repository_provider/repository_provider.dart';
import 'package:nex_music/core/route/go_router/go_router.dart';
import 'package:nex_music/core/services/hive/hive__adapter_model/hive_quality_class.dart';
import 'package:nex_music/core/services/hive/hive__adapter_model/hive_registrar.g.dart';
import 'package:nex_music/core/services/hive_singleton.dart';
import 'package:nex_music/core/theme/theme.dart';
import 'package:nex_music/helper_function/storage_permission/storage_permission.dart';
import 'package:nex_music/network_provider/home_data/download_provider.dart';
import 'package:nex_music/presentation/auth/screens/auth_screen.dart';
import 'package:nex_music/presentation/splash/screens/splash_with_router.dart';
import 'package:nex_music/repository/auth_repository/auth_repository.dart';
import 'package:nex_music/repository/db_repository/db_repository.dart';
import 'package:nex_music/repository/downlaod_repository/download_repository.dart';
import 'package:nex_music/repository/home_repo/repository.dart';
import 'package:nex_music/secrets/firebase_options.dart';
import 'package:nex_music/utils/audioutils/audio_handler.dart';
import 'package:nex_music/wrapper/global_download_listener.dart';
import 'package:path_provider/path_provider.dart';

final audioPlayer = AudioPlayer(); //global audioplayer instance
OverlayEntry? overlayEntry;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarDividerColor: Colors.transparent,
  ));

  // Ensure the system UI is visible
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
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
  await Hive.openBox<bool>(thinkBox);
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
            create: (context) => HomesectionBloc(context.read<Repository>(),
                context.read<DbRepository>(), dbInstance),
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
            create: (context) => UpnextBloc(
              songstreamBloc: context.read<SongstreamBloc>(),
            ),
          ),
          BlocProvider(
            create: (context) => SearchBloc(
              context.read<Repository>(),
              context.read<DbRepository>(),
            ),
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
            create: (context) => FullArtistSongBloc(context.read<Repository>()),
          ),
          BlocProvider(
            create: (context) => FullArtistVideoBloc(context.read<Repository>()),
          ),
          BlocProvider(
            create: (context) => FullArtistAlbumBloc(context.read<Repository>()),
          ),
          BlocProvider(
            create: (context) => FullArtistPlaylistBloc(context.read<Repository>()),
          ),
          BlocProvider(
            create: (context) => SearchAlbumBloc(context.read<Repository>()),
          ),
          BlocProvider(
            create: (context) => RecentplayedBloc(context.read<DbRepository>()),
          ),
          BlocProvider(
            create: (context) => SongDialogBloc(context.read<DbRepository>()),
          ),
          BlocProvider(
            create: (context) => AuthBloc(
              context.read<AuthRepository>(),
              dbInstance,
            ),
          ),
          BlocProvider(
            create: (context) => FavoritesBloc(context.read<DbRepository>()),
          ),
          BlocProvider(
            create: (context) => SavedArtistsBloc(context.read<DbRepository>()),
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
            create: (context) => OfflineSongsBloc(
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
            create: (context) => SleepTimerBloc(),
          ),
          BlocProvider(
            create: (context) => ConnectivityBloc(
              repositoryProviderClassInstance.getConnectivityInstance,
            ),
          ),
          BlocProvider(create: (context) => QualityBloc(dbInstance)),
        ],
        child: BlocListener<UserLoggedBloc, UserLoggedState>(
          listenWhen: (previous, current) => previous is LoggedInState && current is! LoggedInState,
          listener: (context, state) {
            // Clear router cache when user logs out
            AppRouter.clearCache();
          },
          child: BlocBuilder<UserLoggedBloc, UserLoggedState>(
            builder: (context, state) {
              if (state is LoggedInState) {
                // User is logged in, get cached router (or create new one)
                final router = AppRouter.createRouter(
                  repositoryProviderClassInstance.getFirebaseAuthInstance.currentUser!,
                );
                
                return MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  title: 'Nex Music',
                  theme: themeData(context),
                  routerConfig: router,
                  builder: (context, child) {
                    return GlobalDownloadListenerWrapper(
                      child: SplashWithRouter(
                        appLinks: applink,
                        firebaseAuth: repositoryProviderClassInstance.getFirebaseAuthInstance,
                        child: child!,
                      ),
                    );
                  },
                );
              } else {
                // User is not logged in, show auth screen
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: 'Nex Music',
                  theme: themeData(context),
                  home: const AuthScreen(),
                  builder: (context, child) {
                    return GlobalDownloadListenerWrapper(
                      child: child!,
                    );
                  },
                );
              }
            },
          ),
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
