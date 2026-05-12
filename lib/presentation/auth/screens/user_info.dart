
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nex_music/helper_function/general/convert_to_ist.dart';

class UserInfo extends StatelessWidget {
  static const routeName = "/userinfo";
  final User? currentUser;
  
  const UserInfo({super.key, this.currentUser});

  @override
  Widget build(BuildContext context) {
    final user = currentUser ?? 
        (ModalRoute.of(context)?.settings.arguments as User?);
    
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('User information not available'),
        ),
      );
    }
    
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(
            children: [
              const SizedBox(width: 8),
              const Icon(Icons.arrow_back_ios, color: Colors.red, size: 20),
              Text(
                'Settings',
                style: TextStyle(color: Colors.red, fontSize: 17, backgroundColor: theme.scaffoldBackgroundColor),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 10.0),
            child: Text(
              "Profile",
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
          ),
            const SizedBox(height: 20),

            // --- PROFILE IMAGE SECTION ---
            Center(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: user.photoURL != null
                          ? NetworkImage(user.photoURL!)
                          : null,
                      child: user.photoURL == null
                          ? Icon(CupertinoIcons.person_fill,
                              size: 60, color: theme.dividerColor)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.displayName ?? "User",
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Security Badge
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(CupertinoIcons.checkmark_shield_fill,
                          color: Colors.green, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "Your account is secure",
                        style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- USER DATA SECTION ---
            _buildSectionHeader(context, "PERSONAL INFORMATION"),
            _buildGroupedContainer(context, [
              _buildInfoTile(context, "Name", user.displayName ?? "Not Set"),
              Divider(height: 1, indent: 20, color: theme.dividerColor),
              _buildInfoTile(context, "Email", user.email ?? "Not Set"),
            ]),

            _buildSectionHeader(context, "METADATA"),
            _buildGroupedContainer(context, [
              _buildInfoTile(context, "Registered On",
                  convertUkToIst(user.metadata.creationTime!)),
              Divider(height: 1, indent: 20, color: theme.dividerColor),
              _buildInfoTile(context, "Last Sign-In",
                  convertUkToIst(user.metadata.lastSignInTime!)),
            ]),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }


  Widget _buildSectionHeader(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 8, top: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildGroupedContainer(BuildContext context, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoTile(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 15,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
