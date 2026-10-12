import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/phone_guard.dart';
import '../../l10n/app_localizations.dart';
import '../../models/geo_place.dart';
import '../../services/location_service.dart';
import '../../widgets/route_track.dart';
import '../../widgets/snack.dart';

/// Formulaire d'une course, commun a la demande directe et a la demande
/// ouverte : lieu de recuperation, lieu de livraison (adresse et/ou GPS),
/// note. Les deux lieux sont relies par le trace de course.
class RouteForm extends StatefulWidget {
  const RouteForm({
    super.key,
    required this.header,
    required this.submitLabel,
    required this.submitIcon,
    required this.onSubmit,
  });

  /// Bloc affiche au-dessus du trajet (livreur choisi, explication...).
  final Widget header;
  final String submitLabel;
  final IconData submitIcon;

  /// Envoi ; une exception laisse le formulaire rempli et affiche l'erreur.
  final Future<void> Function(GeoPlace pickup, GeoPlace delivery, String note)
      onSubmit;

  @override
  State<RouteForm> createState() => _RouteFormState();
}

class _RouteFormState extends State<RouteForm> {
  final _formKey = GlobalKey<FormState>();
  final _pickupCtrl = TextEditingController();
  final _deliveryCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  Position? _pickupGps;
  Position? _deliveryGps;
  bool _locatingPickup = false;
  bool _locatingDelivery = false;
  bool _sending = false;

  @override
  void dispose() {
    _pickupCtrl.dispose();
    _deliveryCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _share({required bool pickup}) async {
    final t = AppLocalizations.of(context)!;
    setState(() => pickup ? _locatingPickup = true : _locatingDelivery = true);
    try {
      final pos = await LocationService.currentPosition();
      if (!mounted) return;
      setState(() => pickup ? _pickupGps = pos : _deliveryGps = pos);
    } on LocationException catch (e) {
      if (mounted) showSnack(context, locationMessage(t, e.problem));
    } catch (_) {
      if (mounted) showSnack(context, t.locationUnknown);
    } finally {
      if (mounted) {
        setState(() {
          _locatingPickup = false;
          _locatingDelivery = false;
        });
      }
    }
  }

  GeoPlace _place(TextEditingController ctrl, Position? gps) => GeoPlace(
        address: ctrl.text.trim(),
        latitude: gps?.latitude,
        longitude: gps?.longitude,
      );

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _sending = true);
    try {
      await widget.onSubmit(
        _place(_pickupCtrl, _pickupGps),
        _place(_deliveryCtrl, _deliveryGps),
        _noteCtrl.text,
      );
    } catch (_) {
      if (mounted) showSnack(context, AppLocalizations.of(context)!.genericError);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          widget.header,
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 18, 16, 18),
              child: Column(
                children: [
                  _StopField(
                    first: true,
                    label: t.pickup,
                    controller: _pickupCtrl,
                    hasGps: _pickupGps != null,
                    locating: _locatingPickup,
                    onShare: () => _share(pickup: true),
                    onClear: () => setState(() => _pickupGps = null),
                  ),
                  _StopField(
                    first: false,
                    label: t.delivery,
                    controller: _deliveryCtrl,
                    hasGps: _deliveryGps != null,
                    locating: _locatingDelivery,
                    onShare: () => _share(pickup: false),
                    onClear: () => setState(() => _deliveryGps = null),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _noteCtrl,
            maxLines: 3,
            maxLength: 300,
            decoration: InputDecoration(
              labelText: t.noteOptional,
              hintText: t.noteHint,
              alignLabelWithHint: true,
            ),
            validator: (v) => containsPhoneNumber(v ?? '') ? t.phoneNotAllowed : null,
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            style: AppTheme.goButton,
            onPressed: _sending ? null : _submit,
            icon: _sending
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.navy),
                  )
                : Icon(widget.submitIcon),
            label: Text(widget.submitLabel),
          ),
        ],
      ),
    );
  }
}

class _StopField extends StatelessWidget {
  const _StopField({
    required this.first,
    required this.label,
    required this.controller,
    required this.hasGps,
    required this.locating,
    required this.onShare,
    required this.onClear,
  });

  /// Recuperation (point orange, relie a l'etape suivante) ou livraison (epingle).
  final bool first;
  final String label;
  final TextEditingController controller;
  final bool hasGps;
  final bool locating;
  final VoidCallback onShare;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.text.titleSmall),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(hintText: t.addressHint),
          validator: (v) {
            final value = (v ?? '').trim();
            if (value.isEmpty && !hasGps) return t.placeRequired;
            if (containsPhoneNumber(value)) return t.phoneNotAllowed;
            return null;
          },
        ),
        const SizedBox(height: 8),
        if (hasGps)
          InputChip(
            avatar: const Icon(Icons.check_circle, color: AppTheme.success, size: 18),
            label: Text(t.gpsShared),
            onDeleted: onClear,
            deleteButtonTooltipMessage: t.remove,
            shape: const StadiumBorder(),
            side: BorderSide(color: AppTheme.success.withValues(alpha: 0.4)),
          )
        else
          ActionChip(
            avatar: locating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location_rounded, size: 18),
            label: Text(t.shareMyPosition),
            onPressed: locating ? null : onShare,
            shape: const StadiumBorder(),
            side: BorderSide(color: Theme.of(context).dividerColor, width: 1.5),
          ),
        if (first) const SizedBox(height: 22),
      ],
    );
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 22,
            child: Column(
              children: [
                SizedBox(height: first ? 4 : 0),
                if (first) const RouteDot() else const RoutePin(),
                if (first) const Expanded(child: DashedLine()),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: content),
        ],
      ),
    );
  }
}
