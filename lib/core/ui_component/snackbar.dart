import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nex_music/core/theme/hexcolor.dart';

void showSnackbar(BuildContext context, double screenSize, String message) {
  Fluttertoast.cancel();
  Fluttertoast.showToast(
    backgroundColor: secondaryColor,
    msg: message,
    gravity: ToastGravity.BOTTOM,
    toastLength: Toast.LENGTH_SHORT,
    fontSize: screenSize * 0.0200,
    textColor: textColor,
  );
  // return ScaffoldMessenger.of(context)
  //   ..hideCurrentSnackBar()
  //   ..showSnackBar(
  //     SnackBar(
  //       content: Text(
  //         message,
  //         maxLines: 1,
  //         overflow: TextOverflow.ellipsis,
  //       ),
  //       behavior: SnackBarBehavior.fixed,
  //       elevation: 0,
  //       showCloseIcon: true,
  //     ),
  //   );
}
