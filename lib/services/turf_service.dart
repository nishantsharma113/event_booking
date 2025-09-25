// Turf service
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/turf.dart';

class TurfService {
  final supabase = Supabase.instance.client;

  Future<List<Turf>> fetchTurfs() async {
    final data = await supabase.from('turfs').select();
    return (data as List).map((e) => Turf.fromJson(e)).toList();
  }

  Future<Turf> createTurf({
    required String name,
    required String location,
    required double pricePerHour,
    String? description,
    List<String>? images,
  }) async {
    final insert = await supabase.from('turfs').insert({
      'name': name,
      'location': location,
      'price_per_hour': pricePerHour,
      'description': description,
      'images': images,
    }).select().single();
    return Turf.fromJson(insert);
  }

  Future<Turf> updateTurf({
    required String id,
    String? name,
    String? location,
    double? pricePerHour,
    String? description,
    List<String>? images,
  }) async {
    final update = await supabase
        .from('turfs')
        .update({
          if (name != null) 'name': name,
          if (location != null) 'location': location,
          if (pricePerHour != null) 'price_per_hour': pricePerHour,
          if (description != null) 'description': description,
          if (images != null) 'images': images,
        })
        .eq('id', id)
        .select()
        .single();
    return Turf.fromJson(update);
  }

  Future<void> deleteTurf(String id) async {
    await supabase.from('turfs').delete().eq('id', id);
  }

  Future<int> countTurfs() async {
    final data = await supabase.from('turfs').select('id');
    return (data as List).length;
  }
}
