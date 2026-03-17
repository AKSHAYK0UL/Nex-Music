// import 'package:app_links/app_links.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:nex_music/bloc/homesection_bloc/homesection_bloc.dart';
// import 'package:nex_music/core/ui_component/snackbar.dart';
// import 'package:nex_music/presentation/home/navbar/persistent_nav_bar/persistent_nav_bar.dart';
// import 'package:nex_music/presentation/saved/screens/saved.dart';
// import 'package:nex_music/presentation/splash/widgets/splash_widget.dart';

// class SplashScreen extends StatefulWidget {
//   final AppLinks appLinks;
//   final FirebaseAuth firebaseAuth;

//   const SplashScreen(
//       {super.key, required this.appLinks, required this.firebaseAuth});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     context.read<HomesectionBloc>().add(GetHomeSectonDataEvent());

//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: BlocBuilder<HomesectionBloc, HomesectionState>(
//         buildWhen: (previous, current) => previous != current,
//         builder: (context, state) {
//           if (state is HomeSectionState) {
//             return PersistentNavBar(
//               currentUser: widget.firebaseAuth.currentUser!,
//             );
//           }
//           if (state is ErrorState) {
//             //show saved section only
//             showSnackbar(context, "No internet connection");
//             return const SavedSongs(
//               isoffline: true,
//             );
//           }
//           if (state is LoadingState) {
//             return const SplashWidget();
//           }

//           return const SavedSongs(
//             isoffline: true,
//           );
//         },
//       ),
//     );
//   }
// }
//##################################################################################
// import 'package:app_links/app_links.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:nex_music/bloc/homesection_bloc/homesection_bloc.dart';
// import 'package:nex_music/core/ui_component/snackbar.dart';
// import 'package:nex_music/presentation/home/navbar/persistent_nav_bar/persistent_nav_bar.dart';
// import 'package:nex_music/presentation/saved/screens/saved.dart';
// import 'package:nex_music/presentation/splash/widgets/splash_widget.dart';

// class SplashScreen extends StatefulWidget {
//   final AppLinks appLinks;
//   final FirebaseAuth firebaseAuth;

//   const SplashScreen({
//     super.key,
//     required this.appLinks,
//     required this.firebaseAuth,
//   });

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Fetch data
//     context.read<HomesectionBloc>().add(GetHomeSectonDataEvent());
    
//     // Set status bar to dark icons for the white background
//     SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       statusBarIconBrightness: Brightness.dark,
//     ));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: BlocBuilder<HomesectionBloc, HomesectionState>(
//         buildWhen: (previous, current) => previous != current,
//         builder: (context, state) {
//           if (state is HomeSectionState) {
//             return PersistentNavBar(
//               currentUser: widget.firebaseAuth.currentUser!,
//             );
//           }
//           if (state is ErrorState) {
//             showSnackbar(context, "No internet connection");
//             return const SavedSongs(isoffline: true);
//           }
          
//           // Show the new Apple-designed loading UI
//           return const SplashWidget();
//         },
//       ),
//     );
//   }
// }