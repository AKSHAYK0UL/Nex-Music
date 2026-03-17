
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SplashWidget extends StatelessWidget {
  const SplashWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Container(
      width: double.infinity,
      color: Colors.white, 
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: screenHeight * 0.12,
                width: screenHeight * 0.12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    "assets/icon.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              const Text(
                "Nex Music",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                   fontFamily: 'serif',
                  letterSpacing: -0.8, 
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 32),
              
               CupertinoActivityIndicator(
                radius: 12,
                color: Colors.red.withValues(alpha: 0.8),
              ),
            ],
          ),

          Positioned(
            bottom: 5,
            child: Column(
              children: [
                Text(
                  "POWERED BY",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    
                    letterSpacing: 2.5, 
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "KOUL CLOUD",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}