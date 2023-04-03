import 'dart:async';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class StorageService {
  //static const _tokenBoxName = 'tokenBox';
  static const _coursesBoxName = 'coursesBox';

  static Future<void> initHive() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
  }

  static Future<void> saveToken(String token) async {
    final box = await Hive.openBox('authBox');
    await box.put('token', token);
  }

  static Future<String?> getToken() async {
    final box = await Hive.openBox('authBox');
    return box.get('token');
  }

  static Future<void> deleteToken() async {
    final box = await Hive.openBox('authBox');
    await box.delete('token');
  }

  static Future<void> saveCourses(List<dynamic> courses) async {
    final coursesBox = await Hive.openBox(_coursesBoxName);
    await coursesBox.put('courses', courses);
  }
}
