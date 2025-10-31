// Turf provider
import 'dart:developer';
import 'dart:io';
import 'package:event_booking/core/utils/library.dart';
import '../services/turf_service.dart';
import 'package:path/path.dart' as path;

class TurfProvider with ChangeNotifier {
  final TurfService _service = TurfService();

  List<Turf> turfs = [];
  bool isLoading = false;
  String? errorMessage;
  List<String> uploadedImages = [];
  final SupabaseClient supabase = Supabase.instance.client;
  List<String> selectSlotList = [];
  Future<void> loadTurfs() async {
    try {
      isLoading = true;
      notifyListeners();
      turfs = await _service.fetchTurfs();
    } catch (e) {
      log("Error loading turfs: $e");
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
      final urls = await uploadMultipleImages();
      final created = await _service.createTurf(
        name: turf.name,
        location: turf.location,
        pricePerHour: turf.pricePerHour,
        description: turf.description,
        images: urls,
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
      final images = turf.images!
          .where(
            (img) =>
                !img.startsWith('http') &&
                !img.startsWith('http://') &&
                !img.startsWith('https://') &&
                !img.startsWith('www.'),
          )
          .toList();

      uploadedImages = images;

      final urls = await uploadMultipleImages();

      final updated = await _service.updateTurf(
        id: turf.id,
        name: turf.name,
        location: turf.location,
        pricePerHour: turf.pricePerHour,
        description: turf.description,
        images: urls,
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

  Turf? getTurfById(String id) {
    try {
      return turfs.firstWhere((t) => t.id == id);
    } catch (e) {
      log("Error getting turf by ID: $e");
      return null;
    }
  }

  uploadImages(List<String> paths) {
    uploadedImages = paths;
    notifyListeners();
  }

  removeImage(String path) {
    uploadedImages.remove(path);
    notifyListeners();
  }

  Future<List<String>> uploadMultipleImages() async {
    if (uploadedImages.isEmpty) return [];

    List<String> uploadedUrls = [];

    for (var image in uploadedImages) {
      try {
        final file = File(image);
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${path.basename(image)}';
        final filePath = 'images/$fileName';

        await supabase.storage
            .from(AppText.turfBucketName)
            .upload(
              filePath,
              file,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: false,
              ),
            );

        final publicUrl = supabase.storage
            .from(AppText.turfBucketName)
            .getPublicUrl(filePath);
        uploadedUrls.add(publicUrl);
      } catch (e) {
        debugPrint('Error uploading image: $e');
      }
    }

    return uploadedUrls;
  }

  List<String> generateTimeList({
    int startHour = 6,
    int endHour = 23,
    int intervalMinutes = 30,
  }) {
    List<String> times = [];
    DateTime startTime = DateTime(2025, 1, 1, startHour, 0);
    DateTime endTime = DateTime(2025, 1, 1, endHour, 0);

    while (startTime.isBefore(endTime) || startTime.isAtSameMomentAs(endTime)) {
      times.add(formatTime(startTime));
      startTime = startTime.add(Duration(minutes: intervalMinutes));
    }

    return times;
  }

  String formatTime(DateTime time) {
    int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    String minute = time.minute.toString().padLeft(2, '0');
    String period = time.hour >= 12 ? "PM" : "AM";
    return "$hour:$minute $period";
  }

  getSlot() {
    return generateTimeList();
  }

  selectSlots(final slots) {
    if (selectSlotList.contains(slots)) {
      selectSlotList.remove(slots);
    } else {
      selectSlotList.add(slots);
    }

    notifyListeners();
  }
  clearSlots() {
    selectSlotList = [];
    notifyListeners();
  }
}
