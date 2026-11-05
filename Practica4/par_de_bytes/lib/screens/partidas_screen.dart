import 'package:flutter/material.dart';
import '../services/save_service.dart';
import 'game_screen.dart';

class PartidasScreen extends StatefulWidget {
  const PartidasScreen({super.key});

  @override
  State<PartidasScreen> createState() => _PartidasScreenState();
}

class _PartidasScreenState extends State<PartidasScreen> {
  final _servicio = SaveService();
  late Future<List<PartidaGuardada>> _futuro = _servicio.listar();

  void _recargar() => setState(() => _futuro = _servicio.listar());

  String _fecha(DateTime d) {
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(d.day)}/${dos(d.month)}/${d.year} ${dos(d.hour)}:${dos(d.minute)}';
  }

  String _tamano(int bytes) =>
      bytes < 1024 ? '$bytes B' : '${(bytes / 1024).toStringAsFixed(1)} KB';

  Future<void> _eliminar(PartidaGuardada p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar partida'),
        content: Text('¿Eliminar "${p.nombre}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok == true) {
      await _servicio.eliminar(p.ruta);
      _recargar();
    }
  }

  Future<void> _abrir(PartidaGuardada p) async {
    if (p.estado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Archivo dañado: ${p.error}')),
      );
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GameScreen(modo: p.estado!.modo, inicial: p.estado)),
    );
    _recargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Partidas guardadas')),
      body: FutureBuilder<List<PartidaGuardada>>(
        future: _futuro,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error al listar partidas: ${snap.error}'));
          }
          final partidas = snap.data!;
          if (partidas.isEmpty) return const Center(child: Text('No hay partidas guardadas'));
          return ListView.builder(
            itemCount: partidas.length,
            itemBuilder: (_, i) {
              final p = partidas[i];
              final detalle = p.estado == null
                  ? 'Error: ${p.error}'
                  : '${p.estado!.modo} · ${p.estado!.puntuacion} pts · ${p.formato.toUpperCase()}';
              return ListTile(
                leading: Icon(p.estado == null ? Icons.error_outline : Icons.save),
                title: Text(p.nombre),
                subtitle: Text('$detalle\n${_tamano(p.tamano)} · ${_fecha(p.modificada)}'),
                isThreeLine: true,
                onTap: () => _abrir(p),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Eliminar',
                  onPressed: () => _eliminar(p),
                ),
              );
            },
          );
        },
      ),
    );
  }
}