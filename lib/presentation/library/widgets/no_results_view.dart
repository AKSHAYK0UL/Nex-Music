import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NoResultsView extends StatelessWidget {
  final String message;
  final IconData icon;

  const NoResultsView({
    super.key,
    required this.message,
    this.icon = CupertinoIcons.search,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 60,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
