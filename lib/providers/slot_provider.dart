// Slot provider
import 'package:flutter/material.dart';
import '../models/slot.dart';
import '../services/slot_service.dart';

class SlotProvider with ChangeNotifier {
  final SlotService _service = SlotService();

  String? selectedTurfId;
  DateTime visibleMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  List<Slot> slots = [];
  bool isLoading = false;
  String? errorMessage;

  void setTurf(String? turfId) {
    selectedTurfId = turfId;
    notifyListeners();
  }

  void setMonth(DateTime monthStart) {
    visibleMonth = monthStart;
    notifyListeners();
  }

  Future<void> loadSlots() async {
    if (selectedTurfId == null) return;
    try {
      isLoading = true;
      notifyListeners();
      final from = DateTime(visibleMonth.year, visibleMonth.month, 1);
      final to = DateTime(visibleMonth.year, visibleMonth.month + 1, 0, 23, 59, 59);
      slots = await _service.fetchSlots(turfId: selectedTurfId!, from: from, to: to);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSlot(Slot s) async {
    await _service.createSlot(
      turfId: s.turfId,
      date: s.date,
      timeRange: s.timeRange,
      price: s.price,
    );
    await loadSlots();
  }

  Future<void> updateSlotItem(Slot s) async {
    await _service.updateSlot(
      id: s.id,
      date: s.date,
      timeRange: s.timeRange,
      price: s.price,
      isBooked: s.isBooked,
    );
    await loadSlots();
  }

  Future<void> deleteSlotById(String id) async {
    await _service.deleteSlot(id);
    await loadSlots();
  }
}
