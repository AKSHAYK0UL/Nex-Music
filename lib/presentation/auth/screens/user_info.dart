import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/core/ui_component/signing_out_loading.dart';
import 'package:nex_music/helper_function/general/convert_to_ist.dart';
import 'package:nex_music/presentation/auth/widgets/user_info_title.dart';
import 'package:nex_music/presentation/setting/screen/setting.dart';

class UserInfo extends StatelessWidget {
  static const routeName = "/userinfo";
  const UserInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final currentUser = ModalRoute.of(context)?.settings.arguments as User;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Account Detail",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Are You Sure?"),
                  content: const Text("Are you sure you want to Sign Out?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("No"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const SigningOutLoading()));
                      },
                      child: const Text("Yes"),
                    )
                  ],
                ),
              );
            },
            icon: Icon(
              Icons.logout,
              color: Colors.red,
              size: screenSize.height * 0.0329,
            ),
          ),
          IconButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(QualitySettingsScreen.routeName);
              },
              icon: const Icon(Icons.settings)),
        ],
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
