import 'package:flutter/material.dart';
import 'pages/form_builder_page.dart';

void main() {
  runApp(const FormBuilderApp());
}

class FormBuilderApp extends StatelessWidget {
  const FormBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Forms Builder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A8A)),
        useMaterial3: true,
        textTheme: const TextTheme(
          bodySmall: TextStyle(fontSize: 12.5),
          bodyMedium: TextStyle(fontSize: 14),
          bodyLarge: TextStyle(fontSize: 16),
          titleMedium: TextStyle(fontSize: 18),
        ),
      ),
      home: const FormBuilderPage(),
    );
  }
}
