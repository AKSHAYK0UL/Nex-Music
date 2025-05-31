import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/hexcolor.dart';

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

class ModalsheetIconButton extends StatelessWidget {
  const ModalsheetIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        modalsheet(context);
      },
      icon: Icon(
        Icons.expand_less,
        size: 28,
        color: textColor,
      ),
    );
  }
}
