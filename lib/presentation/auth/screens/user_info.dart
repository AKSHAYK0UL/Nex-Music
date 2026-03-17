
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
    
    const Color iosBackgroundColor = Color(0xFFF2F2F7);

    return Scaffold(
      backgroundColor: iosBackgroundColor,
      appBar: AppBar(
        backgroundColor: iosBackgroundColor,
        elevation: 0,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Row(
            children: [
              SizedBox(width: 8),
              Icon(Icons.arrow_back_ios, color: Colors.red, size: 20),
              Text(
                'Settings',
                style: TextStyle(color: Colors.red, fontSize: 17),
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
            const Padding(
            padding: EdgeInsets.only(left: 16.0, bottom: 10.0),
            child: Text(
              "Profile",
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black,
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
                      backgroundColor: Colors.white,
                      backgroundImage: user.photoURL != null
                          ? NetworkImage(user.photoURL!)
                          : null,
                      child: user.photoURL == null
                          ? const Icon(CupertinoIcons.person_fill,
                              size: 60, color: Color(0xFFC6C6C8))
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.displayName ?? "User",
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
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
                            color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- USER DATA SECTION ---
            _buildSectionHeader("PERSONAL INFORMATION"),
            _buildGroupedContainer([
              _buildInfoTile("Name", user.displayName ?? "Not Set"),
              const Divider(height: 1, indent: 20, color: Color(0xFFC6C6C8)),
              _buildInfoTile("Email", user.email ?? "Not Set"),
            ]),

            _buildSectionHeader("METADATA"),
            _buildGroupedContainer([
              _buildInfoTile("Registered On",
                  convertUkToIst(user.metadata.creationTime!)),
              const Divider(height: 1, indent: 20, color: Color(0xFFC6C6C8)),
              _buildInfoTile("Last Sign-In",
                  convertUkToIst(user.metadata.lastSignInTime!)),
            ]),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }


  Widget _buildSectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 8, top: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF6E6E72),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildGroupedContainer(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 15,
                color: Color(0xFF8E8E93),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
