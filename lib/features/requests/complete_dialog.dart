import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';

/// Montant maximum accepte (aligne sur firestore.rules).
const int kMaxDeliveryAmount = 1000000;

/// Demande au livreur le montant de la livraison qu'il termine.
/// Retourne le montant en DA, ou null si le livreur annule.
Future<int?> askDeliveryAmount(BuildContext context) {
  return showDialog<int>(
    context: context,
    builder: (_) => const _AmountDialog(),
  );
}

class _AmountDialog extends StatefulWidget {
  const _AmountDialog();

  @override
  State<_AmountDialog> createState() => _AmountDialogState();
}

class _AmountDialogState extends State<_AmountDialog> {
  final _controller = TextEditingController();
  bool _invalid = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = int.tryParse(_controller.text.trim());
    if (value == null || value < 0 || value > kMaxDeliveryAmount) {
      setState(() => _invalid = true);
      return;
    }
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(t.completeDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.completeDialogHint),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(7),
            ],
            decoration: InputDecoration(
              labelText: t.amountLabel,
              prefixIcon: const Icon(Icons.payments_outlined),
              errorText: _invalid ? t.amountInvalid : null,
            ),
            onChanged: (_) {
              if (_invalid) setState(() => _invalid = false);
            },
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.cancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(t.completeConfirm),
        ),
      ],
    );
  }
}
