import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stock_valuation_app/features/auth/presentation/login_screen.dart';
import 'package:stock_valuation_app/features/dashboard/presentation/dashboard_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter router(RouterRef ref) {
  // TODO: Add auth state listening for redirection
  
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const DashboardScreen(),
      ),
      // Add more routes here
    ],
  );
}
