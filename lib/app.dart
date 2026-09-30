import 'package:flutter/material.dart';
import 'config/constants.dart';
import 'config/theme.dart';
import 'router.dart';

class ArriveApp extends StatelessWidget {
  const ArriveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: appRouter,
    );
  }
}
