import 'package:flutter/material.dart';

import '../../core/constants/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import 'price_sheet.dart';

/// Negociation du prix d'une course, chacun a son tour : le livreur propose,
/// l'autre accepte, contre-propose (-10 / +10 DA) ou refuse. Commun a la
/// demande directe et aux offres d'une demande ouverte, pour les deux roles.
///
/// L'accord ([onAccept]) est conclu par le serveur : course comptee, frais
/// du livreur, telephones et adresse exacte partages.
class NegotiationPanel extends StatelessWidget {
  const NegotiationPanel({
    super.key,
    required this.asDriver,
    required this.price,
    required this.lastBy,
    required this.otherName,
    required this.busy,
    required this.onPropose,
    required this.onAccept,
    this.onRefuse,
    this.refuseLabel,
    this.feeDa = 0,
    this.debt = 0,
  });

  final bool asDriver;

  /// Prix en cours ; null tant que le livreur n'a rien propose.
  final int? price;

  /// driver | client : auteur de [price].
  final String? lastBy;
  final String otherName;
  final bool busy;

  /// Proposition ou contre-proposition.
  final Future<void> Function(int price) onPropose;
  final Future<void> Function() onAccept;

  /// Refus ; null si le refus se fait ailleurs (annulation par le client).
  final Future<void> Function()? onRefuse;
  final String? refuseLabel;

  /// Frais du livreur a l'accord (formule a la livraison) et son solde actuel.
  final int feeDa;
  final int debt;

  String get _me => asDriver ? 'driver' : 'client';

  bool get _myTurn => asDriver ? (price == null || lastBy == 'client') : lastBy == 'driver';

  Future<void> _propose(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final value = await pickPrice(
      context,
      title: price == null ? t.proposePriceTitle : t.counterTitle(otherName),
      hint: price == null
          ? t.proposePriceHint
          : t.counterHint(formatAmount(price!)),
      confirmLabel: t.proposeAction,
      initial: price,
    );
    if (value != null) await onPropose(value);
  }

  Future<void> _accept(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final body = StringBuffer(t.agreeBody(otherName));
    if (asDriver && feeDa > 0) {
      body.write('\n\n');
      body.write(t.agreeFee(
        '$feeDa',
        formatAmount(debt + feeDa),
        formatAmount(AppConfig.debtLimitDa),
      ));
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.agreeTitle(formatAmount(price!))),
        content: Text(body.toString()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t.cancel)),
          FilledButton(
            style: AppTheme.confirmButton,
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.agreeAction),
          ),
        ],
      ),
    );
    if (ok == true) await onAccept();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final p = price;
    final mine = lastBy == _me;

    final String label;
    String? sub;
    if (p == null) {
      label = asDriver ? t.proposePriceHint : t.waitingDriverPrice(otherName);
    } else if (mine) {
      label = t.yourProposal;
      sub = t.waitingAnswer(otherName);
    } else {
      label = t.otherProposes(otherName);
    }

    // Le refus est un lien discret sous les actions, dans tous les etats.
    final refuse = onRefuse == null
        ? null
        : Align(
            alignment: AlignmentDirectional.center,
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: context.ink(AppTheme.danger),
                minimumSize: const Size(0, 40),
              ),
              onPressed: busy ? null : onRefuse,
              child: Text(refuseLabel ?? t.reject),
            ),
          );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.orange.withValues(alpha: context.isDark ? 0.14 : 0.07),
        borderRadius: BorderRadius.circular(AppTheme.radiusControl + 2),
        border: Border.all(color: AppTheme.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: context.text.titleSmall),
                    if (sub != null) Text(sub, style: context.text.bodySmall),
                  ],
                ),
              ),
              if (p != null)
                Text(t.amountDa(formatAmount(p)), style: context.text.headlineSmall),
            ],
          ),
          if (busy) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ] else if (_myTurn && p == null) ...[
            const SizedBox(height: 12),
            FilledButton(
              style: AppTheme.goButton,
              onPressed: () => _propose(context),
              child: Text(t.proposePriceTitle),
            ),
            ?refuse,
          ] else if (_myTurn) ...[
            const SizedBox(height: 12),
            FilledButton(
              style: AppTheme.confirmButton,
              onPressed: () => _accept(context),
              child: Text(t.acceptAmount(formatAmount(p!))),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => _propose(context),
              child: Text(t.counterAction),
            ),
            ?refuse,
          ] else if (refuse != null) ...[
            const SizedBox(height: 4),
            refuse,
          ],
        ],
      ),
    );
  }
}
