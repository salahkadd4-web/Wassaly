import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../models/delivery_request.dart';

/// Pastille d'etat : point de couleur + libelle, sur fond teinte.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;

  /// Icone a la place du point (etats qui ne sont pas un "voyant").
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final fg = context.ink(color);
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(8, 4, 10, 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: context.isDark ? 0.20 : 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(icon, size: 14, color: fg)
          else
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: context.text.labelMedium?.copyWith(
                color: fg,
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
      case RequestStatus.negotiating:
        return StatusChip(
          label: t.statusNegotiating,
          color: AppTheme.orange,
          icon: Icons.swap_vert_rounded,
        );
      case RequestStatus.accepted:
        return StatusChip(label: t.statusAccepted, color: AppTheme.blue);
      case RequestStatus.rejected:
        return StatusChip(label: t.statusRejected, color: AppTheme.danger);
      case RequestStatus.completed:
        return StatusChip(
          label: t.statusCompleted,
          color: AppTheme.success,
          icon: Icons.check_rounded,
        );
      case RequestStatus.cancelled:
        return StatusChip(label: t.statusCancelled, color: AppTheme.neutral);
      default:
        return StatusChip(label: t.statusPending, color: AppTheme.orange);
    }
  }
}

/// Pastille de statut d'abonnement :
/// trial | paid | per_delivery | blocked | expired | suspended.
class SubscriptionChip extends StatelessWidget {
  const SubscriptionChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    switch (status) {
      case 'paid':
        return StatusChip(label: t.subPaid, color: AppTheme.success);
      case 'trial':
        return StatusChip(label: t.subTrial, color: AppTheme.orange);
      case 'per_delivery':
        return StatusChip(label: t.subPerDelivery, color: AppTheme.blue);
      case 'blocked':
        return StatusChip(
          label: t.subBlocked,
          color: AppTheme.danger,
          icon: Icons.lock_outline,
        );
      case 'suspended':
        return StatusChip(
          label: t.subSuspended,
          color: AppTheme.danger,
          icon: Icons.pause_rounded,
        );
      default:
        return StatusChip(label: t.subExpired, color: AppTheme.danger);
    }
  }
}
