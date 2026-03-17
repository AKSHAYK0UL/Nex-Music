import 'package:flutter/material.dart';

// THEME CONSTANTS 
const Color kPrimary = Color(0xFFE53935);
const Color kBackground = Color(0xFFFFFFFF);
const Color kCardDark = Color(0xFF1A2744);
const Color kTextPrimary = Color(0xFF0D0D0D);
const Color kTextSecondary = Color(0xFF8A8A8A);
const Color kDivider = Color(0xFFEEEEEE);

// DATA MODELS 

class PlaylistModel {
  final String name;
  final String subtitle;
  final String songCount;
  final Color color;
  const PlaylistModel(this.name, this.subtitle, this.songCount, this.color);
}



// SHARED WIDGETS 

class AppSearchBar extends StatelessWidget {
  final String hint;
  const AppSearchBar({super.key, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          const Icon(Icons.search, color: kTextSecondary, size: 20),
          const SizedBox(width: 8),
          Text(hint,
              style: const TextStyle(color: kTextSecondary, fontSize: 15)),
        ],
      ),
    );
  }
}

class CircleIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const CircleIconBtn({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: kTextPrimary.withOpacity(0.06),
          shape: BoxShape.circle,
          border: Border.all(color: kTextPrimary.withOpacity(0.12), width: 1.5),
        ),
        child: Icon(icon, color: kTextPrimary, size: 22),
      ),
    );
  }
}
