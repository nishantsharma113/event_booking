// Booking screen
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/booking_service.dart';
import '../../models/slot.dart';
import '../../models/booking.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime date = DateTime.now();
  Slot? selectedSlot;
  final BookingService _bookingService = BookingService();
  List<Booking> _userBookings = [];
  bool _loadingBookings = false;

  @override
  void initState() {
    super.initState();
    _fetchUserBookings();
  }

  Future<void> _fetchUserBookings() async {
    setState(() => _loadingBookings = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;
    if (userId != null) {
      final allBookings = await _bookingService.fetchBookings();
      setState(() {
        _userBookings = allBookings.where((b) => b.userId == userId).toList();
        _loadingBookings = false;
      });
    } else {
      setState(() => _loadingBookings = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Booking')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isWide
            ? Row(
                children: [
                  Expanded(
                    child: _BookingSummary(date: date, slot: selectedSlot),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _SlotPicker(
                      onChange: (s) => setState(() => selectedSlot = s),
                    ),
                  ),
                ],
              )
            : ListView(
                children: [
                  _BookingSummary(date: date, slot: selectedSlot),
                  const SizedBox(height: 16),
                  _SlotPicker(
                    onChange: (s) => setState(() => selectedSlot = s),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'My Bookings',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  _loadingBookings
                      ? Center(child: CircularProgressIndicator())
                      : _userBookings.isEmpty
                      ? Text('No bookings found.')
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _userBookings.length,
                          itemBuilder: (context, idx) {
                            final booking = _userBookings[idx];
                            return Card(
                              child: ListTile(
                                title: Text('Slot: ${booking.slotId}'),
                                subtitle: Text(
                                  'Status: ${booking.status}\nBooked At: ${booking.bookedAt?.toLocal().toString().split(' ').first ?? '-'}',
                                ),
                                trailing: Text(
                                  '₹${booking.totalPrice.toStringAsFixed(0)}',
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton(
            onPressed: selectedSlot == null ? null : _bookSlot,
            child: const Text('Book Slot'),
          ),
        ),
      ),
    );
  }

  void _bookSlot() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;
    final slot = selectedSlot;
    if (userId == null || slot == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('User or slot not selected.')));
      return;
    }
    try {
      await _bookingService.createBooking(
        turfId: slot.turfId,
        userId: userId,
        slotId: slot.id,
        totalPrice: slot.price,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking confirmed and saved to database!')),
      );
      _fetchUserBookings();
    } catch (e) {
      
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Booking failed: $e')));
    }
  }
}

class _BookingSummary extends StatelessWidget {
  final DateTime date;
  final Slot? slot;
  const _BookingSummary({required this.date, required this.slot});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Green Field Arena',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('Date: ${date.toLocal().toString().split(' ').first}'),
            const SizedBox(height: 8),
            Text('Slot: ${slot?.timeRange ?? '-'}'),
            const SizedBox(height: 8),
            const Text('Total: ₹1200'),
          ],
        ),
      ),
    );
  }
}

class _SlotPicker extends StatelessWidget {
  final ValueChanged<Slot> onChange;
  const _SlotPicker({required this.onChange});

  @override
  Widget build(BuildContext context) {
    // Example slot list, replace with real data from provider
    final slots = List.generate(
      8,
      (i) => Slot(
        id: 'slot_$i',
        turfId: 'turf_id_1',
        date: DateTime.now(),
        timeRange: '${10 + i}:00 - ${11 + i}:00',
        price: 1200.0,
        isBooked: false,
      ),
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in slots)
              ChoiceChip(
                label: Text(s.timeRange),
                selected: false,
                onSelected: (_) => onChange(s),
              ),
          ],
        ),
      ),
    );
  }
}
