import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/hexcolor.dart';
// import 'package:lottie/lottie.dart';

Widget loadingDisk() {
  return Center(
    child: CircularProgressIndicator(
      color: accentColor,
    ),
  );
}

// Widget loadingDisk() {
//   return Center(
//     child: Lottie.asset(
//       "assets/loadingdisk.json",
//       height: 115,
//       width: 115,
//     ),
//   );
// }
