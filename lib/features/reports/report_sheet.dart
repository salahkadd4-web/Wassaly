import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/snack.dart';
import '../auth/auth_providers.dart';
import 'report_repository.dart';

/// Lien discret "Signaler ce livreur" (client).
class ReportDriverLink extends ConsumerWidget {
  const ReportDriverLink({
    super.key,
    required this.driverId,
    required this.driverName,
    this.requestId,
  });

  final String driverId;
  final String driverName;
  final String? requestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    return TextButton.icon(
      style: TextButton.styleFrom(
        foregroundColor: context.muted,
        textStyle: context.text.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        minimumSize: const Size(0, 40),
      ),
      onPressed: () => showReportSheet(
        context,
        driverId: driverId,
        driverName: driverName,
        requestId: requestId,
      ),
      icon: const Icon(Icons.flag_outlined, size: 18),
      label: Text(t.reportDriver),
    );
  }
}

Future<void> showReportSheet(
  BuildContext context, {
  required String driverId,
  required String driverName,
  String? requestId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _ReportSheet(
      driverId: driverId,
      driverName: driverName,
      requestId: requestId,
    ),
  );
}

class _ReportSheet extends ConsumerStatefulWidget {
  const _ReportSheet({
    required this.driverId,
    required this.driverName,
    this.requestId,
  });

  final String driverId;
  final String driverName;
  final String? requestId;

  @override
  ConsumerState<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends ConsumerState<_ReportSheet> {
  final _noteCtrl = TextEditingController();
  String _reason = ReportReason.offApp;
  bool _sending = false;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  String _label(AppLocalizations t, String reason) => switch (reason) {
        ReportReason.offApp => t.reportReasonOffApp,
        ReportReason.notDelivered => t.reportReasonNotDelivered,
        ReportReason.behavior => t.reportReasonBehavior,
        _ => t.reportReasonOther,
      };

  Future<void> _send() async {
    final t = AppLocalizations.of(context)!;
    final me = ref.read(authStateProvider).value;
    if (me == null) return;
    setState(() => _sending = true);
    try {
      await ref.read(reportRepositoryProvider).report(
            clientId: me.uid,
            driverId: widget.driverId,
            reason: _reason,
            note: _noteCtrl.text,
            requestId: widget.requestId,
          );
      if (!mounted) return;
      Navigator.pop(context);
      showSnack(context, t.reportSent);
    } on ReportNotAllowedException {
      if (mounted) showSnack(context, t.reportNotAllowed);
    } catch (_) {
      if (mounted) showSnack(context, t.genericError);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(t.reportTitle(widget.driverName), style: context.text.titleLarge),
              const SizedBox(height: 6),
              Text(
                t.reportIntro,
                style: context.text.bodyMedium?.copyWith(color: context.muted),
              ),
              const SizedBox(height: 12),
              RadioGroup<String>(
                groupValue: _reason,
                onChanged: (v) => setState(() => _reason = v ?? _reason),
                child: Column(
                  children: [
                    for (final r in ReportReason.all)
                      RadioListTile<String>(
                        value: r,
                        title: Text(_label(t, r)),
                        contentPadding: EdgeInsets.zero,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteCtrl,
                maxLines: 3,
                maxLength: 300,
                decoration: InputDecoration(labelText: t.reportNoteLabel),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _sending ? null : _send,
                child: _sending
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(t.reportSend),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
