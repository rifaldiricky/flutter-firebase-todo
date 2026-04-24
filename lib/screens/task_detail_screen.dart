import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  String formatTime(String time) {
    if (time.length > 10 && int.tryParse(time) != null) {
      var date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
      return "${date.day}-${date.month}-${date.year} ${date.hour}:${date.minute}";
    }
    return time;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Task Detail")),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // HERO UNTUK JUDUL
              Hero(
                tag: "title_${task.createdAt}",
                child: Material(
                  type: MaterialType.transparency,
                  child: Text(
                    task.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),

              const Text(
                "Deskripsi:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                task.description.isEmpty
                    ? "Tidak ada deskripsi."
                    : task.description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 30),

              // HERO UNTUK TANGGAL
              const Text(
                "Dibuat pada:",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Hero(
                tag: "date_${task.createdAt}",
                child: Material(
                  type: MaterialType.transparency,
                  child: Text(
                    formatTime(task.createdAt),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blueGrey,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
