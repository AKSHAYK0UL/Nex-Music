import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/core/ui_component/signing_out_loading.dart';
import 'package:sidebar_with_animation/animated_side_bar.dart';

// Custom scroll behavior that disables scrolling.
class NoScrollBehavior extends ScrollBehavior {
  const NoScrollBehavior();

// hide/disable the scrollbar
  @override
  Widget buildScrollbar(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const NeverScrollableScrollPhysics();
  }
}

class NavRail extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  const NavRail({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 700;

    return Stack(
      children: [
        ScrollConfiguration(
          behavior: const NoScrollBehavior(),
          child: SideBarAnimated(
            borderRadius: 12,
            settingsDivider: true,
            mainLogoImage: "assets/image.png",
            sideBarColor: secondaryColor,
            splashColor: backgroundColor,
            animatedContainerColor: backgroundColor,
            selectedIconColor: secondaryColor,
            unselectedIconColor: textColor,
            dividerColor: Colors.white,
            hoverColor: Colors.white10,
            highlightColor: backgroundColor,
            sidebarItems: [
              SideBarItem(
                iconUnselected: Icons.home_outlined,
                iconSelected: Icons.home,
                text: "Home",
              ),
              SideBarItem(
                iconUnselected: Icons.music_note_outlined,
                iconSelected: Icons.music_note,
                text: "Recent",
              ),
              SideBarItem(
                iconUnselected: Icons.playlist_play,
                iconSelected: Icons.playlist_play_rounded,
                text: "Playlist",
              ),
              SideBarItem(
                iconUnselected: CupertinoIcons.heart,
                iconSelected: CupertinoIcons.heart_fill,
                text: "Favorites",
              ),
              SideBarItem(
                iconUnselected: Icons.tune_outlined,
                iconSelected: Icons.tune,
                text: "Preferences",
              ),
            ],
            onTap: onTap,
            widthSwitch: 700,
          ),
        ),
        Visibility(
          visible: !isSmallScreen,
          child: Positioned(
            top: 50,
            left: 105,
            child: Text(
              "Nex Music",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
        Positioned(
          bottom: 48,
          left: 40,
          child: TextButton.icon(
            style: TextButton.styleFrom(
              overlayColor: Colors.white10,
            ),
            label: Text(
              isSmallScreen ? "" : "Logout",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.red),
            ),
            onPressed: () {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Are You Sure?"),
                  content: const Text("Do you want to Logout?"),
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
            icon: const Icon(
              Icons.logout_sharp,
              size: 26,
              color: Colors.red,
            ),
          ),
        ),
      ],
    );
  }
}
