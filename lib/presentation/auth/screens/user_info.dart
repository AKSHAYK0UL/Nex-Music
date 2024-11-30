import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/auth_bloc/bloc/auth_bloc.dart';
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/core/ui_component/animatedtext.dart';
import 'package:nex_music/core/ui_component/cacheimage.dart';
import 'package:nex_music/helper_function/general/convert_to_ist.dart';
import 'package:nex_music/presentation/auth/screens/auth_screen.dart';
import 'package:nex_music/presentation/auth/widgets/user_info_title.dart';

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
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("No"),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(SignOutEvent());
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const AuthScreen(),
                          ),
                          (route) => false,
                        );
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
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(screenSize.height * 0.0923),
            child: CircleAvatar(
              radius: screenSize.height * 0.0923,
              child: cacheImage(
                imageUrl: currentUser.photoURL,
                width: screenSize.height * 0.395,
                height: screenSize.height * 0.395,
              ),
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.center,
            child: Chip(
              backgroundColor: Colors.transparent,
              side: const BorderSide(color: Colors.transparent),
              avatar: const Icon(
                Icons.check,
                color: Colors.green,
              ),
              label: animatedText(
                text: "Your account is secure",
                style: Theme.of(context).textTheme.bodyMedium!,
              ),
            ),
          ),
          Card(
            elevation: screenSize.height * 0.00200,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(screenSize.height * 0.0131),
            ),
            margin: EdgeInsets.symmetric(
              horizontal: screenSize.height * 0.0110,
              vertical: screenSize.height * 0.0000,
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
                  title: "Last SignIn Time",
                  data: convertUkToIst(currentUser.metadata.lastSignInTime!),
                  screenSize: screenSize,
                ),
                buildUserInfo(
                  context: context,
                  title: "Register On",
                  data: convertUkToIst(currentUser.metadata.creationTime!),
                  screenSize: screenSize,
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
