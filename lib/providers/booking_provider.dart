// Booking provider
import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';

class BookingProvider with ChangeNotifier {
  final BookingService _service = BookingService();

  List<Booking> bookings = [];
  bool isLoading = false;
  String? errorMessage;

  int totalBookings = 0;
  double totalRevenue = 0;
  List<double> monthlyRevenue = List.filled(12, 0);
  DateTime? filterFrom;
  DateTime? filterTo;

  Future<void> loadAll() async {
    try {
      isLoading = true;
      notifyListeners();
      bookings = await _service.fetchBookings();
      totalBookings = await _service.countBookings();
      totalRevenue = await _service.totalRevenue();
      monthlyRevenue = await _service.monthlyRevenueLast12();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<Booking> get filteredBookings {
    return bookings.where((b) {
      if (filterFrom != null && (b.bookedAt == null || b.bookedAt!.isBefore(filterFrom!))) return false;
      if (filterTo != null && (b.bookedAt == null || b.bookedAt!.isAfter(filterTo!))) return false;
      return true;
    }).toList();
  }

  List<double> computeMonthlyRevenueFiltered() {
    final now = DateTime.now();
    final buckets = List<double>.filled(12, 0);
    for (final b in filteredBookings) {
      final created = b.bookedAt;
      if (created == null) continue;
      final diffMonths = (now.year - created.year) * 12 + (now.month - created.month);
      if (diffMonths >= 0 && diffMonths < 12) {
        final idx = 11 - diffMonths;
        buckets[idx] += b.totalPrice;
      }
    }
    return buckets; 
  }

  Future<void> approve(String id) async {
    await _service.updateStatus(id: id, status: 'approved');
    await loadAll();
  }

  Future<void> cancel(String id) async {
    await _service.updateStatus(id: id, status: 'cancelled');
    await loadAll();
  }
}
