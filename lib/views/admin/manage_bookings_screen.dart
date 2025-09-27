// Manage bookings screen
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';

class ManageBookingsScreen extends StatelessWidget {
  const ManageBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<BookingProvider?>();
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Bookings')),
      body: Consumer<BookingProvider>(
        builder: (context, prov, _) {
          if (prov.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: DataTable(
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Turf')),
                DataColumn(label: Text('User')),
                DataColumn(label: Text('Created')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Actions')),
              ],
              rows: [
                for (final b in prov.filteredBookings)
                  DataRow(cells: [
                    DataCell(Text('#${b.id.substring(0, 6)}')),
                    DataCell(Text(b.turfId)),
                    DataCell(Text(b.userId)),
                    DataCell(Text(b.bookedAt?.toString().substring(0, 19) ?? '-')),
                    DataCell(Text(b.status)),
                    DataCell(Row(children: [
                      TextButton(onPressed: () => prov.approve(b.id), child: const Text('Approve')),
                      const SizedBox(width: 8),
                      TextButton(onPressed: () => prov.cancel(b.id), child: const Text('Cancel')),
                    ])),
                  ]),
              ],
            ),
          );
        },
      ),
    );
  }
}
