import 'package:flutter/material.dart';

ScaffoldMessengerState showSnackbar(BuildContext context, String message) {
  return ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        behavior: SnackBarBehavior.fixed,
        elevation: 0,
        showCloseIcon: true,
      ),
    );
}
