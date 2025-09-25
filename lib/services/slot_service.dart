// Slot service
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/slot.dart';

class SlotService {
  final supabase = Supabase.instance.client;

  Future<List<Slot>> fetchSlots({
    required String turfId,
    required DateTime from,
    required DateTime to,
  }) async {
    final data = await supabase
        .from('slots')
        .select()
        .eq('turf_id', turfId)
        .gte('date', from.toIso8601String())
        .lte('date', to.toIso8601String())
        .order('date')
        .order('time_range');
    return (data as List).map((e) => Slot.fromJson(e)).toList();
  }

  Future<Slot> createSlot({
    required String turfId,
    required DateTime date,
    required String timeRange,
    required double price,
  }) async {
    final insert = await supabase
        .from('slots')
        .insert({
          'turf_id': turfId,
          'date': date.toIso8601String(),
          'time_range': timeRange,
          'price': price,
          'is_booked': false,
        })
        .select()
        .single();
    return Slot.fromJson(insert);
  }

  Future<Slot> updateSlot({
    required String id,
    DateTime? date,
    String? timeRange,
    double? price,
    bool? isBooked,
  }) async {
    final update = await supabase
        .from('slots')
        .update({
          if (date != null) 'date': date.toIso8601String(),
          if (timeRange != null) 'time_range': timeRange,
          if (price != null) 'price': price,
          if (isBooked != null) 'is_booked': isBooked,
        })
        .eq('id', id)
        .select()
        .single();
    return Slot.fromJson(update);
  }

  Future<void> deleteSlot(String id) async {
    await supabase.from('slots').delete().eq('id', id);
  }
}


