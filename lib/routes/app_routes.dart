import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/signup_screen.dart';
import '../views/auth/splash_screen.dart';

// User screens
import '../views/user/home_screen.dart';
import '../views/user/turf_details_screen.dart';
import '../views/user/booking_screen.dart';
import '../views/user/my_bookings_screen.dart';
import '../views/user/profile_screen.dart';

// Admin screens
import '../views/admin/admin_dashboard.dart';
import '../views/admin/manage_turfs_screen.dart';
import '../views/admin/manage_slots_screen.dart';
import '../views/admin/manage_bookings_screen.dart';
import '../views/admin/reports_screen.dart';
import '../views/admin/manage_users_screen.dart';

class AppRouter {
  static GoRouter router(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return GoRouter(
      initialLocation: '/splash',
      // Rebuild routes on auth changes
      refreshListenable: authProvider,
      redirect: (context, state) {
        final user = authProvider.currentUser;
        final path = state.uri.toString();

        final isAuthRoute = path == '/login' || path == '/signup' || path == '/splash' || path == '/admin/login';
        final isAdminSection = path.startsWith('/admin') && path != '/admin/login';

        // Not logged in
        if (user == null) {
          if (isAuthRoute) return null;
          // If trying to access admin or user pages, send to appropriate login
          if (isAdminSection) return '/admin/login';
          return '/login';
        }

        // Logged in
        final isAdmin = user.role == 'admin';

        // Prevent non-admin from admin routes
        if (!isAdmin && isAdminSection) {
          return '/home';
        }

        // After login routes go to role homes
        if (isAuthRoute) {
          return isAdmin ? '/admin/dashboard' : '/home';
        }

        return null;
      },
      routes: [
        // Public / Auth
        GoRoute(path: '/splash', builder: (context, state) => SplashScreen()),
        GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
        GoRoute(path: '/signup', builder: (context, state) => SignupScreen()),
        GoRoute(path: '/admin/login', builder: (context, state) => LoginScreen()),

        // User
        GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
        GoRoute(
          path: '/turf/:id',
          builder: (context, state) => TurfDetailsScreen(),
        ),
        GoRoute(path: '/bookings', builder: (context, state) => BookingScreen()),
        GoRoute(path: '/profile', builder: (context, state) => ProfileScreen()),
        GoRoute(path: '/my-bookings', builder: (context, state) => MyBookingsScreen()),

        // Admin
        GoRoute(path: '/admin/dashboard', builder: (context, state) => AdminDashboard()),
        GoRoute(path: '/admin/turfs', builder: (context, state) => ManageTurfsScreen()),
        GoRoute(path: '/admin/slots', builder: (context, state) => ManageSlotsScreen()),
        GoRoute(path: '/admin/bookings', builder: (context, state) => ManageBookingsScreen()),
        GoRoute(path: '/admin/users', builder: (context, state) => ManageUsersScreen()),
        GoRoute(path: '/admin/reports', builder: (context, state) => ReportsScreen()),
      ],
    );
  }
}
