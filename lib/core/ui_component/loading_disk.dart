import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

Widget loadingDisk() {
  return Center(
    child: Lottie.asset(
      "assets/loadingdisk.json",
      height: 125,
      width: 125,
    ),
  );
}
