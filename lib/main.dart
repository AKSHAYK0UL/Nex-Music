import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:nex_music/bloc/homesection_bloc/homesection_bloc.dart';
import 'package:nex_music/bloc/playlist_bloc/playlist_bloc.dart';
import 'package:nex_music/bloc/search_bloc/bloc/search_bloc.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/core/bloc_provider/repository_provider/repository_provider.dart';
import 'package:nex_music/core/route/route.dart';
import 'package:nex_music/core/theme/theme.dart';
import 'package:nex_music/presentation/home/navbar/navbar.dart';
import 'package:nex_music/repository/home_repo/repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        repositoryProvider,
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
            ),
          ),
          BlocProvider(
            create: (context) => SearchBloc(context.read<Repository>()),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'NEX MUSIC',
          theme: themeData(context),
          home: const NavBar(),
          routes: routes,
        ),
      ),
    );
  }
}
