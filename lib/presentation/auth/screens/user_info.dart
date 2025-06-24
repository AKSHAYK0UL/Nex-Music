import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/helper_function/general/convert_to_ist.dart';
import 'package:nex_music/presentation/auth/widgets/user_info_title.dart';

class UserInfo extends StatelessWidget {
  static const routeName = "/userinfo";
  const UserInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final currentUser = ModalRoute.of(context)?.settings.arguments as User;
    // bool isSmallScreen = screenSize.width < 451;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Account",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        // actions: [
        //   if (isSmallScreen)
        //     IconButton(
        //       onPressed: () {
        //         showDialog(
        //           barrierDismissible: false,
        //           context: context,
        //           builder: (context) => AlertDialog(
        //             title: const Text("Are You Sure"),
        //             content: const Text("Do you want to Logout?"),
        //             actions: [
        //               TextButton(
        //                 onPressed: () {
        //                   Navigator.of(context).pop();
        //                 },
        //                 child: const Text("No"),
        //               ),
        //               TextButton(
        //                 onPressed: () {
        //                   Navigator.of(context).push(MaterialPageRoute(
        //                       builder: (context) => const SigningOutLoading()));
        //                 },
        //                 child: const Text("Yes"),
        //               )
        //             ],
        //           ),
        //         );
        //       },
        //       icon: const Icon(
        //         Icons.logout,
        //         size: 27,
        //         color: Colors.red,
        //       ),
        //     ),
        // ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(screenSize.height * 0.166),
                  child: CircleAvatar(
                    backgroundColor: backgroundColor,
                    radius: screenSize.height * 0.166,
                    child: Lottie.asset(
                      "assets/userinfo.json",
                      repeat: false,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Chip(
              backgroundColor: Colors.transparent,
              side: const BorderSide(color: Colors.transparent),
              avatar: const Icon(
                Icons.check,
                color: Colors.green,
              ),
              label: Text(
                "Your account is secure",
                style: Theme.of(context).textTheme.bodyMedium!,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Card(
              elevation: screenSize.height * 0.00200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenSize.height * 0.0131),
              ),
              margin: EdgeInsets.only(
                left: screenSize.height * 0.0110,
                right: screenSize.height * 0.0110,
                bottom: screenSize.height * 0.0110,
              ),
              color: secondaryColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildUserInfo(
                    context: context,
                    title: "Name",
                    data: currentUser.displayName!,
                    screenSize: screenSize,
                  ),
                  buildUserInfo(
                    context: context,
                    title: "Email",
                    data: currentUser.email!,
                    screenSize: screenSize,
                  ),
                  buildUserInfo(
                    context: context,
                    title: "Register On",
                    data: convertUkToIst(currentUser.metadata.creationTime!),
                    screenSize: screenSize,
                  ),
                  buildUserInfo(
                    context: context,
                    title: "Last Sign-In On",
                    data: convertUkToIst(currentUser.metadata.lastSignInTime!),
                    screenSize: screenSize,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
