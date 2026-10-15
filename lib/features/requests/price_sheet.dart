import 'package:flutter/material.dart';

import '../../core/constants/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';

/// Choix d'un prix de course, pour proposer ou contre-proposer : -10 / +10 DA
/// autour de [initial], entre AppConfig.priceMinDa et priceMaxDa, avec des
/// raccourcis. Retourne le prix choisi, ou null si l'utilisateur annule.
Future<int?> pickPrice(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  int? initial,
  String? hint,
}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _PriceSheet(
      title: title,
      confirmLabel: confirmLabel,
      initial: initial,
      hint: hint,
    ),
  );
}

class _PriceSheet extends StatefulWidget {
  const _PriceSheet({
    required this.title,
    required this.confirmLabel,
    this.initial,
    this.hint,
  });

  final String title;
  final String confirmLabel;
  final int? initial;
  final String? hint;

  @override
  State<_PriceSheet> createState() => _PriceSheetState();
}

class _PriceSheetState extends State<_PriceSheet> {
  late int _price;

  @override
  void initState() {
    super.initState();
    final start = widget.initial ?? AppConfig.priceShortcutsDa[2];
    _price = start.clamp(AppConfig.priceMinDa, AppConfig.priceMaxDa);
  }

  void _step(int delta) => setState(() {
        _price = (_price + delta).clamp(AppConfig.priceMinDa, AppConfig.priceMaxDa);
      });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final accent = context.isDark ? const Color(0xFF3D7BF2) : AppTheme.blue;
    Widget stepButton(IconData icon, int delta, bool enabled) => IconButton.filledTonal(
          iconSize: 28,
          style: IconButton.styleFrom(
            minimumSize: const Size(64, 64),
            backgroundColor: context.surfaceAlt,
            foregroundColor: context.colors.onSurface,
          ),
          tooltip: '${delta > 0 ? '+' : ''}$delta',
          onPressed: enabled ? () => _step(delta) : null,
          icon: Icon(icon),
        );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.title, style: context.text.titleLarge),
            if (widget.hint != null) ...[
              const SizedBox(height: 6),
              Text(
                widget.hint!,
                style: context.text.bodyMedium?.copyWith(color: context.muted),
              ),
            ],
            const SizedBox(height: 20),
            // Le prix au centre, -10 / +10 de part et d'autre (toujours dans
            // le meme sens, y compris en arabe).
            Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                children: [
                  stepButton(Icons.remove_rounded, -AppConfig.priceStepDa,
                      _price > AppConfig.priceMinDa),
                  Expanded(
                    child: Text(
                      t.amountDa(formatAmount(_price)),
                      textAlign: TextAlign.center,
                      style: context.text.displaySmall,
                    ),
                  ),
                  stepButton(Icons.add_rounded, AppConfig.priceStepDa,
                      _price < AppConfig.priceMaxDa),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final p in AppConfig.priceShortcutsDa)
                  ChoiceChip(
                    // Montant seul : "DA" est deja ecrit dans le prix affiche.
                    label: Text(
                      '$p',
                      style: context.text.titleSmall?.copyWith(
                        color: _price == p ? Colors.white : null,
                      ),
                    ),
                    selected: _price == p,
                    showCheckmark: false,
                    selectedColor: accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusControl),
                    ),
                    onSelected: (_) => setState(() => _price = p),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.pop(context, _price),
              child: Text(t.confirmWithPrice(widget.confirmLabel, formatAmount(_price))),
            ),
          ],
        ),
      ),
    );
  }
}
