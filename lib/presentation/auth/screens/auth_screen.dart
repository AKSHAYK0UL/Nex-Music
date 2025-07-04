import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:nex_music/bloc/auth_bloc/bloc/auth_bloc.dart';
import 'package:nex_music/core/theme/hexcolor.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  @override
  void initState() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void privacyPolicy() {}

  void userAgreement() {}

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bool isSmallScreen = screenWidth < 451;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenSize * 0.0280, vertical: screenSize * 0.00263),
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, _) => Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(
                        height: isSmallScreen
                            ? screenSize * 0.121
                            : screenSize * 0.200,
                      ),
                      SizedBox(
                        width: isSmallScreen
                            ? double.infinity
                            : screenSize * 0.640,
                        child: Text(
                          'EMBRACE THE RHYTHM, STEP IN, AND LET THE MUSIC FLOW',
                          style: GoogleFonts.sixtyfour(
                            color: accentColor,
                            textStyle:
                                Theme.of(context).textTheme.headlineLarge,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: screenSize * 0.121,
                      ),
                      SizedBox(
                        width: isSmallScreen
                            ? double.infinity
                            : screenSize * 0.640,
                        child: BlocBuilder<AuthBloc, AuthState>(
                          buildWhen: (previous, current) => previous != current,
                          builder: (context, state) {
                            return ElevatedButton.icon(
                              onPressed: state is LoadingState
                                  ? null
                                  : () {
                                      context
                                          .read<AuthBloc>()
                                          .add(GoogleSignInEvent());
                                    },
                              label: state is LoadingState
                                  ? const Text(" Signing In")
                                  : Text("${'\t' * 1} Continue with Google"),
                              icon: state is LoadingState
                                  ? SizedBox(
                                      width: screenSize * 0.070,
                                      height: screenSize * 0.065,
                                      child: LoadingIndicator(
                                        indicatorType: Indicator.pacman,
                                        colors: [accentColor],
                                        strokeWidth: 1,
                                      ),
                                    )
                                  : Icon(
                                      FontAwesomeIcons.google,
                                      size: screenSize * 0.0263,
                                    ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: secondaryColor,
                                textStyle:
                                    Theme.of(context).textTheme.labelLarge,
                                foregroundColor: textColor,
                                iconColor: textColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        screenSize * 0.0329),
                                    side: BorderSide(
                                        color: Colors.blueGrey,
                                        width: screenSize * 0.00197)),
                                minimumSize:
                                    Size(screenSize * 1, screenSize * 0.0659),
                                disabledBackgroundColor: secondaryColor,
                                disabledForegroundColor: textColor,
                                disabledIconColor: textColor,
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: screenSize * 0.0280,
                      ),
                      SizedBox(
                        width: screenWidth * 0.900,
                        child: RichText(
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                  text: "By continuing, you agree to our ",
                                  style:
                                      Theme.of(context).textTheme.displaySmall),
                              TextSpan(
                                  text: "User Agreement",
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: screenSize * 0.0200,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                    decorationStyle: TextDecorationStyle.solid,
                                    decorationColor: Colors.white,
                                    decorationThickness: 1,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      userAgreement();
                                    }),
                              TextSpan(
                                text:
                                    " and acknowledge that you understand the ",
                                style: Theme.of(context).textTheme.displaySmall,
                              ),
                              TextSpan(
                                text: "Privacy Policy",
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: screenSize * 0.0200,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  decorationStyle: TextDecorationStyle.solid,
                                  decorationColor: Colors.white,
                                  decorationThickness: 1,
                                ),
                                // style: Theme.of(context)
                                //     .textTheme
                                //     .displayMedium
                                //     ?.copyWith(
                                //       decoration: TextDecoration.underline,
                                //       decorationStyle:
                                //           TextDecorationStyle.solid,
                                //       decorationColor: Colors.white,
                                //       decorationThickness: 1,
                                //     ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    privacyPolicy();
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: screenSize * 0.020,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
