// import 'package:flutter/material.dart';

// void showSnackbar(BuildContext context, String message) {
//   final screenWiidth = MediaQuery.sizeOf(context).width;
//   bool isSmallScreen = screenWiidth < 451;
//   // Fluttertoast.cancel();
//   // Fluttertoast.showToast(
//   //   backgroundColor: secondaryColor,
//   //   msg: message,
//   //   gravity: ToastGravity.BOTTOM,
//   //   toastLength: Toast.LENGTH_SHORT,
//   //   fontSize: screenSize * 0.0200,
//   //   textColor: textColor,
//   // );
//   ScaffoldMessenger.of(context)
//     ..hideCurrentSnackBar()
//     ..showSnackBar(
//       SnackBar(
//         content: FittedBox(
//           fit: BoxFit.scaleDown,
//           child: Text(
//             message,
//             maxLines: 1,
//             // overflow: TextOverflow.ellipsis,
//           ),
//         ),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
//         behavior: SnackBarBehavior.floating,
//         elevation: 2,
//         // width: 325,
//         width: screenWiidth * 0.211,

//         backgroundColor: const Color.fromARGB(35, 255, 255, 255),
//         showCloseIcon: true,
//       ),
//     );
// }

import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/hexcolor.dart';

void showSnackbar(BuildContext context, String message) {
  final double screenWidth = MediaQuery.sizeOf(context).width;
  bool isSmallScreen = screenWidth < 451;

  final double snackBarWidth =
      isSmallScreen ? screenWidth * 0.65 : screenWidth * 0.211;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            message,
            maxLines: 1,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 2,
        width: snackBarWidth,
        backgroundColor: backgroundColor,
        showCloseIcon: true,
      ),
    );
}
