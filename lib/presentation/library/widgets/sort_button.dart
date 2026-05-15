import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SortButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isDesc;
  final VoidCallback onTap;

  const SortButton({
    super.key,
    required this.label,
    required this.isActive,
    required this.isDesc,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
            ),
          ),
          if (isActive) ...[
            const SizedBox(width: 2),
            Icon(
              isDesc ? CupertinoIcons.arrow_down : CupertinoIcons.arrow_up,
              size: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ],
        ],
      ),
    );
  }
}
