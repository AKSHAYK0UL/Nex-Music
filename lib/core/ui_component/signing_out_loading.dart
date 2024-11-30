import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:lottie/lottie.dart';
import 'package:nex_music/bloc/auth_bloc/bloc/auth_bloc.dart';
import 'package:nex_music/bloc/user_logged_bloc/bloc/user_logged_bloc.dart';
import 'package:nex_music/core/theme/hexcolor.dart';

class SigningOutLoading extends StatefulWidget {
  const SigningOutLoading({super.key});

  @override
  State<SigningOutLoading> createState() => _SigningOutLoadingState();
}

class _SigningOutLoadingState extends State<SigningOutLoading> {
  Timer? _timer;
  @override
  void initState() {
    context.read<AuthBloc>().add(SignOutEvent());
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) {
        final currentState = context.read<UserLoggedBloc>().state;
        if (currentState.runtimeType == UserLoggedInitial) {
          Navigator.of(context).pop();
        } else {
          context.read<AuthBloc>().add(SignOutEvent());
        }
      },
    );

    super.initState();
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Spacer(),
              Lottie.asset(
                "assets/signout.json",
                height: screenSize * 0.527,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: screenSize * 0.0725,
                    height: screenSize * 0.0725,
                    child: LoadingIndicator(
                      indicatorType: Indicator.pacman,
                      colors: [accentColor],
                      strokeWidth: 1,
                    ),
                  ),
                  Text(
                    "${'\t' * 2}Signing Out",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
