import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_app/screens/login.dart';
import '../models/task_model.dart';
import '../services/storage_service.dart';
import '../widgets/loading_skeleton.dart';
import 'task_detail_screen.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final user = FirebaseAuth.instance.currentUser;
  List<Task> tasks = [];
  bool loading = true;
  bool editMode = false;
  bool deleteMode = false;
  int currentTab = 0;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () => loadTasks());
  }

  Future<void> loadTasks() async {
    try {
      final data = await StorageService.loadTasks();
      if (!mounted) return;
      setState(() {
        tasks = data;
        loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => loading = false);
    }
  }

  void addTask() async {
    if (titleController.text.trim().isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('todos')
          .doc(user!.uid)
          .collection(user!.email!)
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
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal simpan ke Cloud: $e")));
    }
  }

  void deleteTask(String docId) {
    FirebaseFirestore.instance
        .collection('todos')
        .doc(user!.uid)
        .collection(user!.email!)
        .doc(docId)
        .delete();
  }

  void toggleTask(String docId, bool currentStatus) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('todos')
        .doc(user.uid)
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

              if (!context.mounted) return;

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
            .doc(user!.uid)
            .collection(user!.email!)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // 1. Cek Error
          if (snapshot.hasError) return const Center(child: Text("Error"));

          // 2. Cek Loading (HARUS return widget agar kode di bawahnya tidak jalan dulu)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingSkeleton();
          }

          // 3. Ambil data (Sekarang variabel docs aman digunakan di seluruh blok di bawah ini)
          final docs = snapshot.data?.docs ?? [];

          // 4. Logika Filter menggunakan variabel docs yang sudah didefinisikan tadi
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
              final data =
                  doc.data()
                      as Map<
                        String,
                        dynamic
                      >; // Typo 'dinamic' sudah diperbaiki ke 'dynamic'

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
