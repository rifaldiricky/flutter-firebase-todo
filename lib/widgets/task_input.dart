import 'package:flutter/material.dart';

class TaskInput extends StatefulWidget {
  final Function(String) onAdd;

  const TaskInput({super.key, required this.onAdd});

  @override
  State<TaskInput> createState() => _TaskInputState();
}

class _TaskInputState extends State<TaskInput> {
  final controller = TextEditingController();

  void submit() {
    widget.onAdd(controller.text);
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),

      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "Tambah task...",
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => submit(),
            ),
          ),

          SizedBox(width: 10),

          ElevatedButton(onPressed: submit, child: Text("Tambah")),
        ],
      ),
    );
  }
}
