import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  Future<void> init() async {
    await Hive.initFlutter();
  }

  Future<SharedPreferences> prefs() => SharedPreferences.getInstance();
}
