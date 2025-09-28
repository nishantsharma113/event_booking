import 'package:flutter/material.dart';

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
            child: Column(
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
                  admin['name'] as String,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  admin['email'] as String,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Chip(
                  label: Text(admin['role'] as String),
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
                    // Example: Clear user session and navigate to login
                    // Replace with your actual logout logic
                    // e.g., context.read<AuthProvider>().logout();
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/login', (route) => false);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
