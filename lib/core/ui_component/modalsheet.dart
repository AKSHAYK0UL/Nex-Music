import 'package:flutter/material.dart';

void modalsheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        color: Colors.red,
        width: double.infinity,
        height: 200,
        child: const Column(
          children: [
            SizedBox(height: 16),
            Text("View Artist", style: TextStyle(color: Colors.white)),
            SizedBox(height: 12),
            Text("Add to Playlist", style: TextStyle(color: Colors.white)),
            SizedBox(height: 12),
            Text("Download", style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    },
  );
}
