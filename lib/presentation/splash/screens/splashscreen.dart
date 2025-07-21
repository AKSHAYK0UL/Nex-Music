import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/homesection_bloc/homesection_bloc.dart';
import 'package:nex_music/core/ui_component/snackbar.dart';
import 'package:nex_music/presentation/home/navbar/screen/navbar.dart';
import 'package:nex_music/presentation/saved/screens/saved.dart';
import 'package:nex_music/presentation/splash/widgets/splash_widget.dart';

class SplashScreen extends StatefulWidget {
  final AppLinks appLinks;
  final FirebaseAuth firebaseAuth;

  const SplashScreen(
      {super.key, required this.appLinks, required this.firebaseAuth});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    context.read<HomesectionBloc>().add(GetHomeSectonDataEvent());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<HomesectionBloc, HomesectionState>(
        buildWhen: (previous, current) => previous != current,
        builder: (context, state) {
          if (state is HomeSectionState) {
            return NavBar(
              appLinks: widget.appLinks,
              firebaseAuth: widget.firebaseAuth,
            );
          }
          if (state is ErrorState) {
            //show saved section only
            showSnackbar(context, "No internet connection");
            return const SavedSongs(
              isoffline: true,
            );
          }
          if (state is LoadingState) {
            return const SplashWidget();
          }

          return const SavedSongs(
            isoffline: true,
          );
        },
      ),
    );
  }
}
