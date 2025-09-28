import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';

class UserBookingScreen extends StatelessWidget {
  const UserBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<BookingProvider, AuthProvider>(
      builder: (context, bookingProvider, authProvider, _) {
        final userId = authProvider.currentUser?.id;
        final bookings = userId == null
            ? []
            : bookingProvider.bookings
                  .where((b) => b.userId == userId)
                  .toList();

        if (bookingProvider.isLoading) {
          return Scaffold(
            appBar: appBarWidget(context: context),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (bookingProvider.errorMessage != null) {
          return Scaffold(
            appBar: appBarWidget(context: context),
            body: Center(child: Text('Error: ${bookingProvider.errorMessage}')),
          );
        }

        String getTurfName(String turfId) {
          if (turfId == 'turf1') return 'Greenfield Arena';
          if (turfId == 'turf2') return 'City Sports Club';
          return turfId;
        }

        String getSlotTime(String slotId) {
          if (slotId == 'slot1') return '6:00 PM - 7:00 PM';
          if (slotId == 'slot2') return '8:00 AM - 9:00 AM';
          return slotId;
        }

        return Scaffold(
          appBar: appBarWidget(context: context),
          body: bookings.isEmpty
              ? const Center(child: Text('No bookings yet.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, idx) {
                    final b = bookings[idx];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.stadium_outlined,
                                  color: Colors.green[700],
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    getTurfName(b.turfId),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                ),
                                Chip(
                                  label: Text(b.status),
                                  backgroundColor: b.status == 'Confirmed'
                                      ? Colors.green[100]
                                      : Colors.orange[100],
                                  labelStyle: TextStyle(
                                    color: b.status == 'Confirmed'
                                        ? Colors.green[800]
                                        : Colors.orange[800],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  b.bookedAt != null
                                      ? '${b.bookedAt!.year}-${b.bookedAt!.month.toString().padLeft(2, '0')}-${b.bookedAt!.day.toString().padLeft(2, '0')}'
                                      : '',
                                ),
                                const SizedBox(width: 18),
                                const Icon(Icons.access_time, size: 18),
                                const SizedBox(width: 6),
                                Text(getSlotTime(b.slotId)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.currency_rupee, size: 18),
                                const SizedBox(width: 6),
                                Text('₹${b.totalPrice.toStringAsFixed(0)}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  appBarWidget({required BuildContext context}) {
    return AppBar(
      leading: IconButton(
        onPressed: () {
          context.canPop() ? context.pop() : context.go('/home');
        },
        icon: Icon(Icons.arrow_back),
      ),
      title: const Text('My Bookings'),
    );
  }
}
