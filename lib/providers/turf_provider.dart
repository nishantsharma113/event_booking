// Turf provider
import 'package:flutter/material.dart';
import '../models/turf.dart';
import '../services/turf_service.dart';

class TurfProvider with ChangeNotifier {
  final TurfService _service = TurfService();

  List<Turf> turfs = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadTurfs() async {
    try {
      isLoading = true;
      notifyListeners();
      turfs = await _service.fetchTurfs();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTurf(Turf turf) async {
    try {
      isLoading = true;
      notifyListeners();
      final created = await _service.createTurf(
        name: turf.name,
        location: turf.location,
        pricePerHour: turf.pricePerHour,
        description: turf.description,
        images: turf.images,
      );
      turfs.add(created);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTurfItem(Turf turf) async {
    try {
      isLoading = true;
      notifyListeners();
      final updated = await _service.updateTurf(
        id: turf.id,
        name: turf.name,
        location: turf.location,
        pricePerHour: turf.pricePerHour,
        description: turf.description,
        images: turf.images,
      );
      final idx = turfs.indexWhere((t) => t.id == updated.id);
      if (idx != -1) turfs[idx] = updated;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTurfById(String id) async {
    try {
      isLoading = true;
      notifyListeners();
      await _service.deleteTurf(id);
      turfs.removeWhere((t) => t.id == id);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
