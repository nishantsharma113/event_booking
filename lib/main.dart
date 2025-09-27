import 'package:event_booking/core/theme/app_theme.dart';
import 'package:event_booking/providers/auth_provider.dart';
import 'package:event_booking/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:event_booking/providers/turf_provider.dart';
import 'package:event_booking/providers/booking_provider.dart';
import 'package:event_booking/providers/slot_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://hnvopicurqcshmuwydlo.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhudm9waWN1cnFjc2htdXd5ZGxvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTczMDU2NDUsImV4cCI6MjA3Mjg4MTY0NX0.c6WoIl8HVqXfW0znnUy-EqObHs10Et-8P--AfL-6PIc',
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..loadCurrentUser(),
        ),
        ChangeNotifierProvider(create: (_) => TurfProvider()..loadTurfs()),
        ChangeNotifierProvider(create: (_) => BookingProvider()..loadAll()),
        ChangeNotifierProvider(create: (_) => SlotProvider()),
        // Load users data on admin usage (manual refresh on screen); optional eager load:
        // context.read<AuthProvider>().loadUsers();
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.router(context);
    return MaterialApp.router(
      title: 'Event Booking',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
