import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/location.dart';
import '../../providers/location_provider.dart';
import '../../services/location_service.dart';

class LocationEditPage extends ConsumerStatefulWidget {
  const LocationEditPage({super.key, this.locationId});
  final String? locationId;

  @override
  ConsumerState<LocationEditPage> createState() => _LocationEditPageState();
}

class _LocationEditPageState extends ConsumerState<LocationEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _lat;
  late TextEditingController _lng;
  late TextEditingController _radius;
  late TextEditingController _repeat;
  late TextEditingController _note;
  bool _enabled = true;
  Location? _existing;

  @override
  void initState() {
    super.initState();
    final idStr = widget.locationId;
    _existing = null;
    if (idStr != null) {
      final list = ref.read(locationListProvider).valueOrNull ?? const <Location>[];
      for (final l in list) {
        if (l.id != null && l.id.toString() == idStr) {
          _existing = l;
          break;
        }
      }
    }
    final l = _existing;
    _name = TextEditingController(text: l?.name ?? '');
    _lat = TextEditingController(text: l?.latitude.toString() ?? '');
    _lng = TextEditingController(text: l?.longitude.toString() ?? '');
    _radius = TextEditingController(text: (l?.radius ?? 50).toString());
    _repeat = TextEditingController(text: (l?.repeatMinutes ?? 0).toString());
    _note = TextEditingController(text: l?.note ?? '');
    _enabled = l?.enabled ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _lat.dispose();
    _lng.dispose();
    _radius.dispose();
    _repeat.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _useCurrent() async {
    final p = await LocationService.instance.getCurrentPosition();
    if (p != null) {
      setState(() {
        _lat.text = p.latitude.toStringAsFixed(6);
        _lng.text = p.longitude.toStringAsFixed(6);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(locationListProvider.notifier);
    final l = Location(
      id: _existing?.id,
      name: _name.text.trim(),
      latitude: double.parse(_lat.text.trim()),
      longitude: double.parse(_lng.text.trim()),
      radius: double.parse(_radius.text.trim()),
      repeatMinutes: int.tryParse(_repeat.text.trim()) ?? 0,
      enabled: _enabled,
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
    );
    if (_existing == null) {
      await notifier.add(l);
    } else {
      await notifier.update(l);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.locationId == null ? 'Add place' : 'Edit place'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _lat,
                    decoration:
                        const InputDecoration(labelText: 'Latitude'),
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                    validator: (v) =>
                        double.tryParse(v ?? '') == null ? 'Invalid' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lng,
                    decoration:
                        const InputDecoration(labelText: 'Longitude'),
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                    validator: (v) =>
                        double.tryParse(v ?? '') == null ? 'Invalid' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(Icons.my_location),
                onPressed: _useCurrent,
                label: const Text('Use current location'),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _radius,
              decoration:
                  const InputDecoration(labelText: 'Radius (meters)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) =>
                  double.tryParse(v ?? '') == null ? 'Invalid' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _repeat,
              decoration: const InputDecoration(
                labelText: 'Repeat every (minutes, 0 = once)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _note,
              decoration: const InputDecoration(labelText: 'Note (optional)'),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Enabled'),
              value: _enabled,
              onChanged: (v) => setState(() => _enabled = v),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
