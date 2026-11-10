// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:nex_music/bloc/download_manager_bloc/bloc/download_manager_bloc.dart';
// import 'package:nex_music/core/theme/hexcolor.dart';
// import 'package:nex_music/model/download_task_model.dart';

// /// FAB shown in the NavBarShell while any download is in progress.
// /// Shows the first actively-downloading task; tapping does nothing (user
// /// manages downloads from the Downloads screen).
// class GlobalDownloadIndicator extends StatelessWidget {
//   const GlobalDownloadIndicator({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<DownloadManagerBloc, DownloadManagerState>(
//       buildWhen: (previous, current) => previous.tasks != current.tasks,
//       builder: (context, state) {
//         // Find the first actively-downloading task to show in the FAB.
//         final downloading = state.tasks.values
//             .where((t) => t.status == DownloadTaskStatus.downloading)
//             .toList();

//         if (downloading.isEmpty) return const SizedBox.shrink();

//         final task = downloading.first;
//         final progress = task.progress.clamp(0.0, 100.0);

//         return SizedBox(
//           height: 70,
//           width: 70,
//           child: FloatingActionButton(
//             backgroundColor: secondaryColor,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(40),
//               side: BorderSide(color: backgroundColor),
//             ),
//             onPressed: null,
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 Container(
//                   width: 56,
//                   height: 56,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     image: DecorationImage(
//                       image: NetworkImage(task.songData.thumbnail),
//                       fit: BoxFit.fill,
//                     ),
//                   ),
//                 ),
//                 CircularProgressIndicator(
//                   color: accentColor,
//                   backgroundColor: secondaryColor,
//                   strokeAlign: 9.0,
//                   strokeWidth: 3,
//                   value: progress / 100,
//                 ),
//                 // Badge showing number of additional downloads.
//                 if (downloading.length > 1)
//                   Positioned(
//                     right: 0,
//                     top: 0,
//                     child: Container(
//                       padding: const EdgeInsets.all(3),
//                       decoration: BoxDecoration(
//                         color: accentColor,
//                         shape: BoxShape.circle,
//                       ),
//                       child: Text(
//                         '+${downloading.length - 1}',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 9,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
