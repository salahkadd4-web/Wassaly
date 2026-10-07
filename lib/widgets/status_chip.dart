import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../models/delivery_request.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pastille de statut d'une demande de livraison.
class RequestStatusChip extends StatelessWidget {
  const RequestStatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    switch (status) {
      case RequestStatus.accepted:
        return StatusChip(
          label: t.statusAccepted,
          color: AppTheme.blue,
          icon: Icons.thumb_up_alt_outlined,
        );
      case RequestStatus.rejected:
        return StatusChip(
          label: t.statusRejected,
          color: AppTheme.danger,
          icon: Icons.block,
        );
      case RequestStatus.completed:
        return StatusChip(
          label: t.statusCompleted,
          color: AppTheme.success,
          icon: Icons.check_circle_outline,
        );
      case RequestStatus.cancelled:
        return StatusChip(
          label: t.statusCancelled,
          color: AppTheme.neutral,
          icon: Icons.cancel_outlined,
        );
      default:
        return StatusChip(
          label: t.statusPending,
          color: AppTheme.orange,
          icon: Icons.schedule,
        );
    }
  }
}

/// Pastille de statut d'abonnement : trial | paid | expired | suspended.
class SubscriptionChip extends StatelessWidget {
  const SubscriptionChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    switch (status) {
      case 'paid':
        return StatusChip(
          label: t.subPaid,
          color: AppTheme.success,
          icon: Icons.verified_outlined,
        );
      case 'trial':
        return StatusChip(
          label: t.subTrial,
          color: AppTheme.orange,
          icon: Icons.hourglass_bottom,
        );
      case 'suspended':
        return StatusChip(
          label: t.subSuspended,
          color: AppTheme.danger,
          icon: Icons.pause_circle_outline,
        );
      default:
        return StatusChip(
          label: t.subExpired,
          color: AppTheme.danger,
          icon: Icons.event_busy,
        );
    }
  }
}
