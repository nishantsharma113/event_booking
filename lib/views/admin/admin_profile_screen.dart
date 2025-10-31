import 'package:event_booking/core/utils/library.dart';
import 'package:event_booking/models/profile.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Replace with actual admin data fetching logic
    final admin = {
      'name': 'Admin User',
      'email': 'admin@example.com',
      'role': 'Administrator',
      'avatarUrl': null, // Replace with actual avatar URL if available
    };

    final authProvider = context.watch<AuthProvider>();
    final Profile? user = authProvider.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Profile')),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: user != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundImage:
                            admin['avatarUrl'] != null &&
                                (admin['avatarUrl'] as String).isNotEmpty
                            ? NetworkImage(admin['avatarUrl'] as String)
                            : null,
                        child:
                            admin['avatarUrl'] == null ||
                                (admin['avatarUrl'] as String).isEmpty
                            ? const Icon(Icons.person, size: 48)
                            : null,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        user.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(user.role),
                        avatar: const Icon(Icons.verified_user, size: 18),
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: ButtonStyle(
                          minimumSize: WidgetStatePropertyAll(Size(200, 48)),
                          fixedSize: WidgetStatePropertyAll(Size(200, 48)),
                        ),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Logout'),
                                content: const Text(
                                  'Are you sure you want to logout?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text('Logout'),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirmed == true) {
                            await authProvider.logout();
                            if (context.mounted) context.go('/login');
                          }
                        },
                      ),
                    ],
                  )
                : SizedBox(),
          ),
        ),
      ),
    );
  }
}
