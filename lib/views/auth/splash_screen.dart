// Splash screen
import '../../core/utils/library.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndRedirect();
  }

  Future<void> _checkAuthAndRedirect() async {
    // Wait a bit for providers to initialize
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    await authProvider.loadCurrentUser();
    final user = authProvider.currentUser;
    debugPrint('SplashScreen: currentUser = $user');
    if (user == null) {
      debugPrint('SplashScreen: No user logged in, redirecting to /login');
      // Not logged in, go to login
      if (mounted) context.go('/login');
    } else {
      // Logged in, redirect based on role

      if (mounted) {
        if (user.role == 'admin') {
          context.go('/admin/dashboard');
        } else {
          context.go('/home');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Loading...', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
