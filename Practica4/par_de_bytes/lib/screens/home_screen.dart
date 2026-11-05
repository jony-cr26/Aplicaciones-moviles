import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'opciones_screen.dart';
import 'partidas_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _ir(BuildContext context, Widget pantalla) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Par de Bytes')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    onPressed: () => _ir(context, const GameScreen(modo: 'clasico')),
                    child: const Text('Modo Clásico (6 pares)'),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => _ir(context, const GameScreen(modo: 'contrarreloj')),
                    child: const Text('Modo Contrarreloj (8 pares, 90 s)'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => _ir(context, const PartidasScreen()),
                    child: const Text('Partidas guardadas'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => _ir(context, const OpcionesScreen()),
                    child: const Text('Opciones'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}