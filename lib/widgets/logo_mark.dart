import 'package:flutter/material.dart';

/// Icone du logo Wassaly (pin + colis) sur tuile blanche arrondie, comme
/// l'icone de l'application (lisible aussi en mode sombre).
class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        border: dark ? null : Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.28),
        child: Image.asset(
          'assets/branding/logo/wassaly_icon.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
