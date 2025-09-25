import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProv = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                FilledButton.icon(
                  onPressed: () => authProv.loadUsers(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
                const SizedBox(width: 12),
                if (authProv.isLoading) const CircularProgressIndicator(),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Phone')),
                    DataColumn(label: Text('Role')),
                    DataColumn(label: Text('Blocked')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: [
                    for (final u in authProv.users)
                      DataRow(cells: [
                        DataCell(Text(u.name)),
                        DataCell(Text(u.email)),
                        DataCell(Text(u.phone ?? '-')),
                        DataCell(Text(u.role)),
                        DataCell(Text('—')),
                        DataCell(Row(children: [
                          if (u.role == 'admin')
                            TextButton(onPressed: () => authProv.demoteToUser(u.id), child: const Text('Demote'))
                          else
                            TextButton(onPressed: () => authProv.promoteToAdmin(u.id), child: const Text('Promote')),
                          const SizedBox(width: 8),
                          TextButton(onPressed: () => authProv.blockUser(u.id), child: const Text('Block')),
                          const SizedBox(width: 8),
                          TextButton(onPressed: () => authProv.unblockUser(u.id), child: const Text('Unblock')),
                        ])),
                      ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


