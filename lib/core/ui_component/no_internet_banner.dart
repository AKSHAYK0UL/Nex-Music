// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/connectivity_bloc/bloc/connectivity_bloc.dart';

class NoInternetBanner extends StatelessWidget {
  final String message;
  const NoInternetBanner({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(message),
          TextButton(
            onPressed: () {
              context
                  .read<ConnectivityBloc>()
                  .add(CheckConnectivityStatusEvent());
            },
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}
