import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/helper_function/general/convert_to_ist.dart';
import 'package:nex_music/presentation/auth/widgets/user_info_title.dart';

class UserInfoDesktop extends StatelessWidget {
  final User currentUser;
  const UserInfoDesktop({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SizedBox(
            height: screenSize.height * 0.695,
            width: screenSize.width * 0.651,
            child: Card(
              color: secondaryColor,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(right: screenSize.width * 0.010),
                      child: Lottie.asset(
                        "assets/accountdesktop.json",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  VerticalDivider(
                    thickness: 1.5,
                    indent: 15,
                    endIndent: 15,
                    color: accentColor,
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(screenSize.height * 0.100),
                          child: CircleAvatar(
                            backgroundColor: secondaryColor,
                            radius: screenSize.height * 0.100,
                            child: Lottie.asset(
                              "assets/userinfo.json",
                              repeat: false,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Chip(
                            backgroundColor: secondaryColor,
                            side: BorderSide(color: secondaryColor),
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
                          flex: 2,
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
                                data: convertUkToIst(
                                    currentUser.metadata.creationTime!),
                                screenSize: screenSize,
                              ),
                              buildUserInfo(
                                context: context,
                                title: "Last Sign-In On",
                                data: convertUkToIst(
                                    currentUser.metadata.lastSignInTime!),
                                screenSize: screenSize,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
