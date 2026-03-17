
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget buildQualityOptions<T>(BuildContext context, List<T> values,
    ValueNotifier<T> notifier, String title) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 20, bottom: 8, top: 10),
        child: Text(
          title.toUpperCase(), 
          style: const TextStyle(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),

      // Grouped Container (White background with rounded corners)
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ValueListenableBuilder<T>(
          valueListenable: notifier,
          builder: (context, selectedQuality, child) {
            return Column(
              children: List.generate(values.length, (index) {
                T quality = values[index];
                final bool isLast = index == values.length - 1;

                return Column(
                  children: [
                    ListTile(
                      onTap: () {
                        notifier.value = quality;
                      },
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      title: Text(
                        quality.toString().split('.').last.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'serif', 
                          color: Colors.black, 
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      trailing: selectedQuality == quality
                          ? const Icon(
                              CupertinoIcons.check_mark,
                              color: CupertinoColors.activeBlue,
                              size: 20,
                            )
                          : null,
                    ),
                    if (!isLast)
                      const Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 0,
                        color: Color(0xFFC6C6C8),
                      ),
                  ],
                );
              }),
            );
          },
        ),
      ),
    ],
  );
}
