import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/download_bloc/bloc/download_bloc.dart';
import 'package:nex_music/bloc/offline_songs_bloc/bloc/offline_songs_bloc.dart';
import 'package:nex_music/core/ui_component/snackbar.dart';

class GlobalDownloadListenerWrapper extends StatelessWidget {
  final Widget child;

  const GlobalDownloadListenerWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<DownloadBloc, DownloadState>(
      listenWhen: (previous, current) => previous != current,
      listener: (context, state) {
        if (state is DownloadCompletedState) {
          context.read<OfflineSongsBloc>().add(LoadOfflineSongsEvent());
          showSnackbar(context, "Download completed");
        }
        if (state is DownloadErrorState) {
          showSnackbar(context, state.errorMessage);
        }
      },
      child: child,
    );
  }
}

// class GlobalDownloadListenerWrapper extends StatelessWidget {
//   final Widget child;

//   // A list of route names where the download indicator should be hidden
//   final List<String> excludedRoutes;
//   const GlobalDownloadListenerWrapper({
//     super.key,
//     required this.child,
//     this.excludedRoutes = const [],
//   });

//   @override
//   Widget build(BuildContext context) {
//     final route = ModalRoute.of(context)?.settings.name;
//     print("Current ROUTE NAME $route @@@@");
//     return Stack(
//       children: [
//         child, // Your app
//         if (!excludedRoutes.contains(route))
//           Positioned(
//             bottom: 150,
//             right: 15,
//             child: BlocConsumer<DownloadBloc, DownloadState>(
//               listenWhen: (previous, current) => previous != current,
//               buildWhen: (previous, current) =>
//                   current is DownloadPercantageStatusState,
//               listener: (context, state) {
//                 if (state is DownloadCompletedState) {
//                   context.read<OfflineSongsBloc>().add(LoadOfflineSongsEvent());
//                   showSnackbar(context, "Download completed");
//                 } else if (state is DownloadErrorState) {
//                   showSnackbar(context, state.errorMessage);
//                 }
//               },
//               builder: (context, state) {
//                 if (state is DownloadPercantageStatusState) {
//                   return SizedBox(
//                     height: 70,
//                     width: 70,
//                     child: FloatingActionButton(
//                       backgroundColor: secondaryColor,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(40),
//                         side: BorderSide(color: backgroundColor),
//                       ),
//                       onPressed: () {},
//                       child: Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           Container(
//                             width: 56,
//                             height: 56,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               image: DecorationImage(
//                                 image: NetworkImage(state.songData.thumbnail),
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                           ),
//                           StreamBuilder<double>(
//                             stream: state.percentageStream,
//                             builder: (context, snapshot) {
//                               if (!snapshot.hasData) {
//                                 return CircularProgressIndicator(
//                                   color: accentColor,
//                                 );
//                               }
//                               return CircularProgressIndicator(
//                                 color: accentColor,
//                                 backgroundColor: secondaryColor,
//                                 strokeWidth: 3,
//                                 strokeAlign: 9.0,
//                                 value: snapshot.data! / 100,
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 }
//                 return const SizedBox();
//               },
//             ),
//           ),
//       ],
//     );
//   }
// }
