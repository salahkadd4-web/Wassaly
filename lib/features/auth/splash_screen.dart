import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/branding/logo/wassaly_logo.png', width: 180),
            const SizedBox(height: 32),
            const SizedBox(
              width: 120,
              child: LinearProgressIndicator(
                minHeight: 4,
                color: AppTheme.orange,
                backgroundColor: Color(0xFFEBEFF6),
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
