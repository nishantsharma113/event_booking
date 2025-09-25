// Booking service
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking.dart';

class BookingService {
  final supabase = Supabase.instance.client;

  Future<List<Booking>> fetchBookings() async {
    final data = await supabase.from('bookings').select();
    return (data as List).map((e) => Booking.fromJson(e)).toList();
  }

  Future<void> updateStatus({required String id, required String status}) async {
    await supabase.from('bookings').update({'status': status}).eq('id', id);
  }

  Future<int> countBookings() async {
    final data = await supabase.from('bookings').select('id');
    return (data as List).length;
  }

  Future<double> totalRevenue() async {
    final data = await supabase.from('bookings').select('total_price');
    double sum = 0;
    for (final row in (data as List)) {
      final val = (row['total_price'] as num?)?.toDouble() ?? 0;
      sum += val;
    }
    return sum;
  }

  Future<List<double>> monthlyRevenueLast12() async {
    final data = await supabase.from('bookings').select('total_price, created_at');
    final now = DateTime.now();
    final buckets = List<double>.filled(12, 0);
    for (final row in (data as List)) {
      final created = DateTime.parse(row['created_at']);
      final diffMonths = (now.year - created.year) * 12 + (now.month - created.month);
      if (diffMonths >= 0 && diffMonths < 12) {
        final idx = 11 - diffMonths;
        buckets[idx] += (row['total_price'] as num).toDouble();
      }
    }
    return buckets;
  }
}
