import 'package:flutter/material.dart';

import '../../core/constants/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';

/// Le livreur choisit le prix de la course dans la liste (pas de saisie
/// libre), avant d'accepter ou de prendre une demande. Le client le voit
/// des l'acceptation ; c'est aussi le montant enregistre a la fin.
///
/// [feeDa] : frais debites au livreur (formule a la livraison), 0 sinon.
/// [debtAfter] : solde du livreur apres ce debit, affiche si [feeDa] > 0.
/// Retourne le prix choisi, ou null si le livreur annule.
Future<int?> pickDeliveryPrice(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  int feeDa = 0,
  int debtAfter = 0,
}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _PriceSheet(
      title: title,
      confirmLabel: confirmLabel,
      feeDa: feeDa,
      debtAfter: debtAfter,
    ),
  );
}

class _PriceSheet extends StatefulWidget {
  const _PriceSheet({
    required this.title,
    required this.confirmLabel,
    required this.feeDa,
    required this.debtAfter,
  });

  final String title;
  final String confirmLabel;
  final int feeDa;
  final int debtAfter;

  @override
  State<_PriceSheet> createState() => _PriceSheetState();
}

class _PriceSheetState extends State<_PriceSheet> {
  int? _price;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.title, style: context.text.titleLarge),
            const SizedBox(height: 6),
            Text(
              t.pricePickHint,
              style: context.text.bodyMedium?.copyWith(color: context.muted),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final p in AppConfig.deliveryPricesDa)
                  ChoiceChip(
                    label: Text(
                      t.amountDa(formatAmount(p)),
                      style: context.text.titleMedium?.copyWith(
                        color: _price == p ? Colors.white : null,
                      ),
                    ),
                    selected: _price == p,
                    showCheckmark: false,
                    selectedColor: context.isDark ? const Color(0xFF3D7BF2) : AppTheme.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusControl),
                    ),
                    onSelected: (_) => setState(() => _price = p),
                  ),
              ],
            ),
            if (widget.feeDa > 0) ...[
              const SizedBox(height: 16),
              Text(
                t.priceSheetFee(
                  '${widget.feeDa}',
                  formatAmount(widget.debtAfter),
                  formatAmount(AppConfig.debtLimitDa),
                ),
                style: context.text.bodySmall,
              ),
            ],
            const SizedBox(height: 18),
            FilledButton(
              style: AppTheme.confirmButton,
              onPressed: _price == null ? null : () => Navigator.pop(context, _price),
              child: Text(
                _price == null
                    ? widget.confirmLabel
                    : t.confirmWithPrice(widget.confirmLabel, formatAmount(_price!)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
