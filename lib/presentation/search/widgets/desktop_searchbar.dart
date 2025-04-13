import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/hexcolor.dart';

class DesktopSearchBar extends StatelessWidget {
  const DesktopSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      height: 87,
      width: 700,
      child: TextField(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          prefix: Padding(
            padding: EdgeInsets.only(left: 10),
            // child: icon,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                VerticalDivider(
                  color: accentColor,
                  thickness: 2,
                  indent: 7.5,
                  endIndent: 7.5,
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.search,
                    size: 30,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),
          border: buildOutlineInputBorder,
          enabledBorder: buildOutlineInputBorder,
          focusedBorder: buildOutlineInputBorder,
          errorBorder: buildOutlineInputBorder,
          focusedErrorBorder: buildOutlineInputBorder,
        ),
      ),
    );
  }
}

OutlineInputBorder get buildOutlineInputBorder {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(25),
    borderSide: BorderSide(color: accentColor, width: 2),
  );
}
