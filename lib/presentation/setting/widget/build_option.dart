import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/hexcolor.dart';

Widget buildQualityOptions<T>(BuildContext context, List<T> values,
    ValueNotifier<T> notifier, String title) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "  $title",
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 08),
      ValueListenableBuilder<T>(
        valueListenable: notifier,
        builder: (context, selectedQuality, child) {
          return Column(
            children: List.generate(values.length, (index) {
              T quality = values[index];

              BorderRadius borderRadius = BorderRadius.zero;
              if (index == 0) {
                borderRadius =
                    const BorderRadius.vertical(top: Radius.circular(15));
              } else if (index == values.length - 1) {
                borderRadius =
                    const BorderRadius.vertical(bottom: Radius.circular(15));
              }

              return GestureDetector(
                onTap: () {
                  notifier.value = quality;
                },
                child: ListTile(
                  contentPadding: const EdgeInsets.only(left: 25, right: 10),
                  shape: RoundedRectangleBorder(borderRadius: borderRadius),
                  title: Text(quality.toString().split('.').last.toUpperCase()),
                  trailing: Radio<T>(
                    overlayColor: WidgetStateColor.resolveWith((_) {
                      return accentColor;
                    }),
                    fillColor: WidgetStateColor.resolveWith((_) {
                      return accentColor;
                    }),
                    value: quality,
                    groupValue: selectedQuality,
                    hoverColor: Colors.white12,
                    onChanged: (value) {
                      if (value != null) {
                        notifier.value = value;
                      }
                    },
                  ),
                ),
              );
            }),
          );
        },
      ),
    ],
  );
}
