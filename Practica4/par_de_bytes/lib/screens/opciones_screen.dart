import 'package:flutter/material.dart';
import '../settings/ajustes.dart';

class OpcionesScreen extends StatelessWidget {
  const OpcionesScreen({super.key});

  Widget _seccion(String titulo, Widget control) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 8), control],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Opciones')),
      body: ListView(
        children: [
          _seccion(
            'Tema',
            ValueListenableBuilder<String>(
              valueListenable: Ajustes.tema,
              builder: (_, t, __) => SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'guinda', label: Text('Guinda')),
                  ButtonSegment(value: 'azul', label: Text('Azul')),
                ],
                selected: {t},
                onSelectionChanged: (s) {
                  Ajustes.tema.value = s.first;
                  Ajustes.persistir();
                },
              ),
            ),
          ),
          _seccion(
            'Formato de guardado',
            ValueListenableBuilder<String>(
              valueListenable: Ajustes.formato,
              builder: (_, f, __) => SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'json', label: Text('JSON')),
                  ButtonSegment(value: 'xml', label: Text('XML')),
                  ButtonSegment(value: 'txt', label: Text('TXT')),
                ],
                selected: {f},
                onSelectionChanged: (s) {
                  Ajustes.formato.value = s.first;
                  Ajustes.persistir();
                },
              ),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: Ajustes.sonido,
            builder: (_, s, __) => SwitchListTile(
              title: const Text('Sonido'),
              value: s,
              onChanged: (v) {
                Ajustes.sonido.value = v;
                Ajustes.persistir();
              },
            ),
          ),
        ],
      ),
    );
  }
}