import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/auth_bloc/bloc/auth_bloc.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/bloc/user_logged_bloc/bloc/user_logged_bloc.dart';

Future<void> handleSignout(BuildContext context) async {
  final authBloc = context.read<AuthBloc>();
  final songstreamBloc = context.read<SongstreamBloc>();
  final userLoggedBloc = context.read<UserLoggedBloc>();

  // Trigger logout
  authBloc.add(SignOutEvent());
  songstreamBloc.add(CloseMiniPlayerEvent());

  late final StreamSubscription subscription;

  subscription = userLoggedBloc.stream.listen((state) {
    if (state is UserLoggedInitial) {
      // Dispose audio player
      songstreamBloc.add(DisposeAudioPlayerEvent());

      if (context.mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/', (route) => false);
      }

      subscription.cancel();
    }
  });

  // Retry sign-out if state doesn't change
  Future.delayed(const Duration(seconds: 2), () {
    if (userLoggedBloc.state is! UserLoggedInitial) {
      authBloc.add(SignOutEvent());
    }
  });
}
