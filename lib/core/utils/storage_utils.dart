import 'package:shared_preferences/shared_preferences.dart';

class StorageUtils {

  static Future<void> storeData(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<String?> readData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> removeData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  removeAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}