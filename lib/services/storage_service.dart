import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

class StorageService {
  static const key = "tasks";

  static Future saveTasks(List<Task> tasks) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> data = tasks.map((task) => jsonEncode(task.toMap())).toList();

    await prefs.setStringList(key, data);
  }

  static Future<List<Task>> loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String>? data = prefs.getStringList(key);

    if (data == null) return [];

    return data.map((task) => Task.fromMap(jsonDecode(task), '')).toList();
  }
}
