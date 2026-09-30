import 'package:go_router/go_router.dart';
import 'pages/main_scaffold.dart';
import 'pages/about_page.dart';
import 'pages/location/location_list_page.dart';
import 'pages/location/location_edit_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/locations',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: '/locations',
          builder: (context, state) => const LocationListPage(),
          routes: [
            GoRoute(
              path: 'edit',
              builder: (context, state) {
                final id = state.uri.queryParameters['id'];
                return LocationEditPage(locationId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/about',
          builder: (context, state) => const AboutPage(),
        ),
      ],
    ),
  ],
);
