// import 'package:flutter/material.dart';
// import 'package:nex_music/core/theme/hexcolor.dart';

// BottomNavigationBarThemeData bottomNavBarTheme(double screenSize) {
//   return BottomNavigationBarThemeData(
//     type: BottomNavigationBarType.fixed,
//     backgroundColor: backgroundColor,
//     elevation: 0,
//     selectedIconTheme: IconThemeData(
//       color: accentColor,
//       size: screenSize * 0.0329,
//     ),
//     selectedLabelStyle: TextStyle(
//       color: textColor,
//       fontSize: screenSize * 0.0211,
//       fontWeight: FontWeight.w600,
//     ),
//     selectedItemColor: textColor,
//     unselectedIconTheme: IconThemeData(
//       color: Colors.grey.shade600,
//       size: screenSize * 0.0303,
//     ),
//     unselectedLabelStyle: TextStyle(
//       color: Colors.grey.shade600,
//       fontSize: screenSize * 0.0211,
//       fontWeight: FontWeight.normal,
//     ),
//     unselectedItemColor: Colors.grey.shade600,
//   );
// }
//=============================================================================
import 'package:flutter/material.dart';

BottomNavigationBarThemeData bottomNavBarTheme(double screenSize) {
  return BottomNavigationBarThemeData(
    type: BottomNavigationBarType.fixed,
    // backgroundColor: backgroundColor,
    backgroundColor: const Color.fromARGB(253, 255, 255, 255),
    elevation: 0,
    selectedIconTheme: IconThemeData(
      // color: accentColor,
      color: const Color(0xFFFF2D55),
      size: screenSize * 0.0320,
    ),
    selectedLabelStyle: TextStyle(
      // color: textColor,
      color: const Color(0xFFFF2D55),

      fontSize: screenSize * 0.0195,
      // fontWeight: FontWeight.w600,
            fontWeight: FontWeight.normal,

    ),
    // selectedItemColor: textColor,
    selectedItemColor: const Color(0xFFFF2D55),

    unselectedIconTheme: IconThemeData(
      // color: Colors.grey.shade600,
      color: Colors.grey,
      size: screenSize * 0.0320,
    ),
    unselectedLabelStyle: TextStyle(
      // color: Colors.grey.shade600,
      color: Colors.grey,

      fontSize: screenSize * 0.0195,
      fontWeight: FontWeight.normal,
    ),
    // unselectedItemColor: Colors.grey.shade600,
    unselectedItemColor: Colors.grey,
  );
}
