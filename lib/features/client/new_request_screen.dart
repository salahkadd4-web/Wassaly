import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/geo_place.dart';
import '../../services/location_service.dart';
import '../../widgets/driver_avatar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/place_input_section.dart';
import '../../widgets/snack.dart';
import '../../widgets/state_views.dart';
import '../auth/auth_providers.dart';
import '../common/home_tab_provider.dart';
import '../drivers/driver_providers.dart';
import '../requests/request_providers.dart';

class NewRequestScreen extends ConsumerStatefulWidget {
  const NewRequestScreen({super.key, required this.driverId});

  final String driverId;

  @override
  ConsumerState<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends ConsumerState<NewRequestScreen> {
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
    setState(() {
      if (pickup) {
        _locatingPickup = true;
      } else {
        _locatingDelivery = true;
      }
    });
    try {
      final pos = await LocationService.currentPosition();
      if (!mounted) return;
      setState(() {
        if (pickup) {
          _pickupGps = pos;
        } else {
          _deliveryGps = pos;
        }
      });
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

  GeoPlace _place(TextEditingController ctrl, Position? gps) {
    return GeoPlace(
      address: ctrl.text.trim(),
      latitude: gps?.latitude,
      longitude: gps?.longitude,
    );
  }

  Future<void> _submit() async {
    final t = AppLocalizations.of(context)!;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final user = ref.read(authStateProvider).value;
    final profile = ref.read(userProfileProvider).value;
    final driver = ref.read(driverProvider(widget.driverId)).value;
    if (user == null || profile == null || driver == null) return;

    setState(() => _sending = true);
    try {
      await ref
          .read(requestRepositoryProvider)
          .create(
            clientId: user.uid,
            clientName: profile.name,
            clientPhone: profile.phone,
            driverId: driver.uid,
            driverName: driver.name,
            pickup: _place(_pickupCtrl, _pickupGps),
            delivery: _place(_deliveryCtrl, _deliveryGps),
            note: _noteCtrl.text,
          );
      if (!mounted) return;
      ref.read(homeTabProvider.notifier).select(1);
      showSnack(context, t.requestSent);
      context.go('/client');
    } catch (_) {
      if (mounted) {
        showSnack(context, t.genericError);
        setState(() => _sending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final driverAsync = ref.watch(driverProvider(widget.driverId));

    return Scaffold(
      appBar: AppBar(title: Text(t.newRequest)),
      body: driverAsync.when(
        loading: () => const LoadingState(),
        error: (_, __) => const ErrorState(),
        data: (driver) {
          if (driver == null) {
            return EmptyState(
              icon: Icons.person_off_outlined,
              message: t.driverNotFound,
            );
          }
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    leading: DriverAvatar(photo: driver.photo, radius: 22),
                    title: Text(driver.name),
                    subtitle: Text(t.requestTo),
                  ),
                ),
                const SizedBox(height: 20),
                PlaceInputSection(
                  title: t.pickup,
                  icon: Icons.upload_outlined,
                  iconColor: AppTheme.orange,
                  controller: _pickupCtrl,
                  hasGps: _pickupGps != null,
                  locating: _locatingPickup,
                  onShare: () => _share(pickup: true),
                  onClear: () => setState(() => _pickupGps = null),
                ),
                const SizedBox(height: 20),
                PlaceInputSection(
                  title: t.delivery,
                  icon: Icons.home_outlined,
                  iconColor: Theme.of(context).colorScheme.primary,
                  controller: _deliveryCtrl,
                  hasGps: _deliveryGps != null,
                  locating: _locatingDelivery,
                  onShare: () => _share(pickup: false),
                  onClear: () => setState(() => _deliveryGps = null),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _noteCtrl,
                  maxLines: 3,
                  maxLength: 300,
                  decoration: InputDecoration(
                    labelText: t.noteOptional,
                    prefixIcon: const Icon(Icons.sticky_note_2_outlined),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _sending ? null : _submit,
                  icon: _sending
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: Text(t.sendToDriver),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
