import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/hexcolor.dart';

class SplashWidget extends StatelessWidget {
  const SplashWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    // final screenWidth = MediaQuery.sizeOf(context).width;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),

          Card(
            elevation: 3,
            color: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            child: Container(
              height: screenHeight * 0.158,
              width: screenHeight * 0.158,
              // width: screenWidth * 0.307,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.asset("assets/icon.png"),
              ),
            ),
          ),

          SizedBox(
            height: screenHeight * 0.297,
          ),
          CircularProgressIndicator(
            color: accentColor,
          ),
          SizedBox(
            height: screenHeight * 0.030,
          ),
          Text(
            "Nex Music",
            style: Theme.of(context).textTheme.titleMedium,
          ),

          Text(
            "Your moment, your music",
            style: Theme.of(context).textTheme.bodySmall,
          ),

          //Powered by KOUL
          SizedBox(
            height: screenHeight * 0.017,
          ),
          // RichText(
          //     text: TextSpan(children: [
          //   TextSpan(
          //     text: "Powered by ",
          //     style: Theme.of(context).textTheme.displaySmall,
          //   ),
          //   TextSpan(
          //     text: "KOUL",
          //     style: Theme.of(context)
          //         .textTheme
          //         .displaySmall
          //         ?.copyWith(fontWeight: FontWeight.bold),
          //   )
          // ])),
          Text(
            "Powered by KOUL",
            style: Theme.of(context).textTheme.labelSmall,
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
