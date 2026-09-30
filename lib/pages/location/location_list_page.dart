import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/location_provider.dart';
import '../../services/geofence_monitor_service.dart';
import '../../utils/distance_utils.dart';

class LocationListPage extends ConsumerStatefulWidget {
  const LocationListPage({super.key});

  @override
  ConsumerState<LocationListPage> createState() => _LocationListPageState();
}

class _LocationListPageState extends ConsumerState<LocationListPage> {
  bool _monitoring = GeofenceMonitorService.instance.isRunning;

  Future<void> _toggleMonitor() async {
    final monitor = GeofenceMonitorService.instance;
    if (monitor.isRunning) {
      monitor.stop();
      setState(() => _monitoring = false);
      return;
    }
    final ok = await monitor.start();
    if (!mounted) return;
    setState(() => _monitoring = ok);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permission denied. Cannot start monitoring.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncLocs = ref.watch(locationListProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arrive'),
        actions: [
          IconButton(
            tooltip: _monitoring ? 'Stop monitoring' : 'Start monitoring',
            icon: Icon(_monitoring ? Icons.location_on : Icons.location_off),
            onPressed: _toggleMonitor,
          ),
        ],
      ),
      body: asyncLocs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Text('No places yet. Tap + to add one.'),
            );
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final loc = list[i];
              final subtitle = '${loc.latitude.toStringAsFixed(5)}, '
                  '${loc.longitude.toStringAsFixed(5)}  '
                  '${DistanceUtils.formatMeters(loc.radius)} radius'
                  '${loc.repeatMinutes > 0 ? ' / every ${loc.repeatMinutes}m' : ''}';
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  title: Text(loc.name),
                  subtitle: Text(subtitle),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () =>
                            context.push('/locations/edit?id=${loc.id}'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => ref
                            .read(locationListProvider.notifier)
                            .remove(loc.id!),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/locations/edit'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
