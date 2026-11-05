import 'package:flutter/material.dart';

void main() => runApp(const ParDeBytesApp());

class ParDeBytesApp extends StatelessWidget {
  const ParDeBytesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Par de Bytes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF6A1B3D), // guinda provisional
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(child: Text('Par de Bytes')),
      ),
    );
  }
}