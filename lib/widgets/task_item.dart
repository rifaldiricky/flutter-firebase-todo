import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final Function(bool?) onChanged;
  final VoidCallback onTap;

  const TaskItem({
    super.key,
    required this.task,
    required this.onChanged,
    required this.onTap,
  });

  String formatTime(String time) {
    if (time.length > 10 && int.tryParse(time) != null) {
      var date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
      return "${date.day}-${date.month}-${date.year}";
    }
    return time;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(value: task.isDone, onChanged: onChanged),
        title: Hero(
          tag: "title_${task.createdAt}", // Tag unik untuk judul
          child: Material(
            type: MaterialType.transparency,
            child: Text(
              task.title,
              style: TextStyle(
                fontSize: 18,
                decoration: task.isDone
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ),
        ),
        subtitle: Hero(
          tag: "date_${task.createdAt}", // Tag unik untuk tanggal
          child: Material(
            type: MaterialType.transparency,
            child: Text(
              formatTime(task.createdAt),
              style: const TextStyle(
                fontSize: 12,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
