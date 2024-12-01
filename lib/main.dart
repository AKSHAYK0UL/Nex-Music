import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:nex_music/bloc/auth_bloc/bloc/auth_bloc.dart';
import 'package:nex_music/bloc/user_logged_bloc/bloc/user_logged_bloc.dart';
import 'package:nex_music/core/bloc_provider/repository_provider/repository_provider.dart';
import 'package:nex_music/core/route/route.dart';
import 'package:nex_music/core/theme/theme.dart';
import 'package:nex_music/presentation/auth/screens/auth_screen.dart';
import 'package:nex_music/presentation/home/navbar/navbar.dart';
import 'package:nex_music/repository/auth_repository/auth_repository.dart';

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
  MyApp(this.repositoryProviderClassInstance, {super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [repositoryProviderClassInstance.authRepositoryProvider],
      child: MultiBlocProvider(
        providers: [
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
                        repositoryProviderClassInstance);
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
