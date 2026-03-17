import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/homesection_bloc/homesection_bloc.dart';
import 'package:nex_music/core/ui_component/snackbar.dart';
import 'package:nex_music/core/route/go_router/go_router.dart';
import 'package:nex_music/presentation/splash/widgets/splash_widget.dart';

class SplashWithRouter extends StatefulWidget {
  final AppLinks appLinks;
  final FirebaseAuth firebaseAuth;
  final Widget child;

  const SplashWithRouter({
    super.key,
    required this.appLinks,
    required this.firebaseAuth,
    required this.child,
  });

  @override
  State<SplashWithRouter> createState() => _SplashWithRouterState();
}

class _SplashWithRouterState extends State<SplashWithRouter> {

  @override
  void initState() {
    super.initState();
    // Fetch data
    context.read<HomesectionBloc>().add(GetHomeSectonDataEvent());

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  Widget build(BuildContext context) {
  

  
    return Scaffold(
      body: BlocListener<HomesectionBloc, HomesectionState>(
        listener: (context, state) {
          if (state is ErrorState) {
            showSnackbar(context, "No internet connection");
            AppRouter.router.go(RouterPath.offlineDownloadsRoute);
          }
        },
        child: BlocBuilder<HomesectionBloc, HomesectionState>(
          buildWhen: (previous, current) => previous != current,
          builder: (context, state) {
            if (state is HomeSectionStateData || state is ErrorState) {
              return widget.child;
            }

            return const SplashWidget();
          },
        ),
      ),
    );
  }
}
