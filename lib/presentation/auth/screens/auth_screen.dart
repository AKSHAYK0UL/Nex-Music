import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/presentation/home/navbar/navbar.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  void privacyPolicy() {}
  void userAgreement() {}

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenSize * 0.0131, vertical: screenSize * 0.00263),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  flex: 11,
                  child: DefaultTextStyle(
                    textAlign: TextAlign.center,
                    style: GoogleFonts.kaushanScript(
                      textStyle: Theme.of(context).textTheme.headlineLarge,
                      letterSpacing: 2,
                    ),
                    child: AnimatedTextKit(
                      repeatForever: true,
                      animatedTexts: [
                        RotateAnimatedText(
                          alignment: Alignment.center,
                          textAlign: TextAlign.center,
                          duration: const Duration(seconds: 4),
                          'FEEL THE BEAT, LIVE THE RHYTHM',
                        ),
                        RotateAnimatedText(
                            alignment: Alignment.center,
                            textAlign: TextAlign.center,
                            duration: const Duration(seconds: 4),
                            'YOUR MOVEMENT, YOUR MUSIC'),
                        RotateAnimatedText(
                            alignment: Alignment.center,
                            textAlign: TextAlign.center,
                            duration: const Duration(seconds: 4),
                            'WHERE WORDS FAIL, MUSIC SPEAKS'),
                        RotateAnimatedText(
                            alignment: Alignment.center,
                            textAlign: TextAlign.center,
                            duration: const Duration(seconds: 4),
                            'LET THE SOUND MOVE YOU'),
                        RotateAnimatedText(
                            alignment: Alignment.center,
                            textAlign: TextAlign.center,
                            duration: const Duration(seconds: 4),
                            'EVERY BEAT, A NEW ADVENTURE'),
                        RotateAnimatedText(
                            alignment: Alignment.center,
                            textAlign: TextAlign.center,
                            duration: const Duration(seconds: 4),
                            'PLAY YOUR RHYTHM, SET YOUR SOUL FREE'),
                        RotateAnimatedText(
                            alignment: Alignment.center,
                            textAlign: TextAlign.center,
                            duration: const Duration(seconds: 4),
                            'MUSIC IS THE KEY TO YOUR HEART\'S RHYTHM'),
                        RotateAnimatedText(
                            alignment: Alignment.center,
                            textAlign: TextAlign.center,
                            duration: const Duration(seconds: 4),
                            'TURN UP THE SOUND, TURN UP THE VIBE'),
                        RotateAnimatedText(
                            alignment: Alignment.center,
                            textAlign: TextAlign.center,
                            duration: const Duration(seconds: 4),
                            'IN EVERY NOTE, THERE\'S A STORY TO TELL'),
                        RotateAnimatedText(
                            alignment: Alignment.center,
                            textAlign: TextAlign.center,
                            duration: const Duration(seconds: 4),
                            'YOUR SOUL\'S SOUNDTRACK, YOUR ENDLESS JOURNEY'),
                        RotateAnimatedText(
                            alignment: Alignment.center,
                            textAlign: TextAlign.center,
                            duration: const Duration(seconds: 4),
                            'DIVE INTO THE MUSIC, LET IT CARRY YOU'),
                        RotateAnimatedText(
                            alignment: Alignment.center,
                            textAlign: TextAlign.center,
                            duration: const Duration(seconds: 4),
                            'RHYTHM FLOWS WHERE YOUR HEART GOES'),
                        RotateAnimatedText(
                            alignment: Alignment.center,
                            textAlign: TextAlign.center,
                            duration: const Duration(seconds: 4),
                            'THE SOUND OF FREEDOM, THE BEAT OF LIFE'),
                        RotateAnimatedText(
                            alignment: Alignment.center,
                            textAlign: TextAlign.center,
                            duration: const Duration(seconds: 4),
                            'DANCE TO YOUR OWN TUNE'),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) {
                        return const NavBar();
                      }));
                    },
                    label: Text("${'\t' * 1} Continue with Google"),
                    icon: Icon(
                      FontAwesomeIcons.google,
                      size: screenSize * 0.0263,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryColor,
                      textStyle: Theme.of(context).textTheme.labelLarge,
                      foregroundColor: textColor,
                      iconColor: textColor,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(screenSize * 0.0329),
                          side: BorderSide(
                              color: Colors.blueGrey,
                              width: screenSize * 0.00197)),
                      minimumSize:
                          Size(screenSize * 0.474, screenSize * 0.0659),
                    ),
                  ),
                ),
                SizedBox(
                  height: screenSize * 0.0171,
                ),
                Expanded(
                  flex: 1,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: "By continuing, you agree to our ",
                            style: Theme.of(context).textTheme.displaySmall),
                        TextSpan(
                            text: "User Agreement",
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium
                                ?.copyWith(
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
                          text: " and acknowledge that you understand the ",
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        TextSpan(
                            text: "Privacy Policy",
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium
                                ?.copyWith(
                                  decoration: TextDecoration.underline,
                                  decorationStyle: TextDecorationStyle.solid,
                                  decorationColor: Colors.white,
                                  decorationThickness: 1,
                                ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                privacyPolicy();
                              }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
