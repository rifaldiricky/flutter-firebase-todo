import 'package:flutter/material.dart';
import 'app_initializer.dart';

void main() {
  // Menjamin engine Flutter siap
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo App Firebase',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      // Pintu masuk utama lewat AppInitializer
      home: const AppInitializer(),
    );
  }
}
