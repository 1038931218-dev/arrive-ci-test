import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indexFor(context),
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              context.go('/locations');
              break;
            case 1:
              context.go('/about');
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.place_outlined),
            selectedIcon: Icon(Icons.place),
            label: '地址',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            label: '关于',
          ),
        ],
      ),
    );
  }

  int _indexFor(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    if (loc.startsWith('/about')) return 1;
    return 0;
  }
}
