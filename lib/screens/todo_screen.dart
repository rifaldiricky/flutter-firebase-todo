import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_app/screens/login.dart';
import '../models/task_model.dart';

import '../widgets/loading_skeleton.dart';
import 'task_detail_screen.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  int currentTab = 0;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> addTask() async {
    if (user == null || titleController.text.trim().isEmpty) return;
    try {
      await FirebaseFirestore.instance
          .collection('todos')
          .doc(user!.uid)
          .collection(user!.email ?? 'tasks')
          .add({
            'title': titleController.text,
            'description': descController.text,
            'completed': false,
            'timestamp': FieldValue.serverTimestamp(),
            'userId': user!.uid,
          });

      titleController.clear();
      descController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal simpan ke Cloud: $e")));
      }
    }
  }

  void deleteTask(String docId) {
    if (user?.email == null) return;
    FirebaseFirestore.instance
        .collection('todos')
        .doc(user!.uid)
        .collection(user!.email!)
        .doc(docId)
        .delete();
  }

  void toggleTask(String docId, bool currentStatus) {
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('todos')
        .doc(user!.uid)
        .collection(user!.email!)
        .doc(docId)
        .update({'completed': !currentStatus});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Tasks"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              if (!mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Login()),
                (route) => false,
              );
            },
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('todos')
            .doc(user?.uid)
            .collection(user?.email ?? 'tasks')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Error"));

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingSkeleton();
          }

          final docs = snapshot.data?.docs ?? [];

          var filteredDocs = docs;
          if (currentTab == 1) {
            filteredDocs = docs.where((d) => d['completed'] == false).toList();
          } else if (currentTab == 2) {
            filteredDocs = docs.where((d) => d['completed'] == true).toList();
          }

          if (filteredDocs.isEmpty) {
            return const Center(child: Text("Belum ada task"));
          }

          return ListView.builder(
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              final doc = filteredDocs[index];
              final data = doc.data() as Map<String, dynamic>;

              final task = Task(
                id: doc.id,
                title: data['title'] ?? '',
                description: data['description'] ?? '',
                isDone: data['completed'] ?? false,
                createdAt: data['timestamp']?.toString() ?? '',
              );

              return buildTaskRow(task, doc.id);
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: showAddDialog,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTab,
        onTap: (index) => setState(() => currentTab = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Semua"),
          BottomNavigationBarItem(icon: Icon(Icons.play_arrow), label: "Aktif"),
          BottomNavigationBarItem(icon: Icon(Icons.check), label: "Selesai"),
        ],
      ),
    );
  }

  Widget buildTaskRow(Task task, String docId) {
    return ListTile(
      leading: Checkbox(
        value: task.isDone,
        onChanged: (_) => toggleTask(docId, task.isDone),
      ),
      title: Text(task.title),
      subtitle: task.description.isNotEmpty ? Text(task.description) : null,
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () => deleteTask(docId),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
        );
      },
    );
  }

  void showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tambah Task"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: "Judul"),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(hintText: "Deskripsi"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              addTask();
              Navigator.pop(context);
            },
            child: const Text("Tambah"),
          ),
        ],
      ),
    );
  }
}
