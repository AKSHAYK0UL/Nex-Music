import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget loadingDisk() {
  return const Center(
    child: CupertinoActivityIndicator(
      color: Colors.red,
      radius: 15,
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
