import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_state.dart';
import '../services/save_service.dart';
import '../settings/ajustes.dart';

const _simbolos = <IconData>[
  Icons.memory, Icons.storage, Icons.bug_report, Icons.wifi,
  Icons.code, Icons.usb, Icons.keyboard, Icons.router,
];

class GameScreen extends StatefulWidget {
  final String modo; // 'clasico' | 'contrarreloj'
  final GameState? inicial; // si viene de una partida guardada
  const GameScreen({super.key, required this.modo, this.inicial});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const limiteContrarreloj = 90;

  late String _modo;
  late int _nivel;
  late List<int> _tablero;
  late List<int> _emparejadas;
  late List<String> _movimientos;
  late List<String> _etiquetas;
  late int _tiempo;
  final List<int> _volteadas = [];
  bool _bloqueado = false;
  bool _terminado = false;
  Timer? _reloj;

  bool get _esContrarreloj => _modo == 'contrarreloj';

  int get _puntos {
    final pares = _emparejadas.length ~/ 2;
    final fallos = max(0, _movimientos.length - pares);
    return max(0, pares * 100 - fallos * 10);
  }

  @override
  void initState() {
    super.initState();
    final s = widget.inicial;
    if (s != null) {
      _modo = s.modo;
      _nivel = s.nivel;
      _tablero = List.of(s.tablero);
      _emparejadas = List.of(s.emparejadas);
      _movimientos = List.of(s.movimientos);
      _etiquetas = List.of(s.etiquetas);
      _tiempo = s.tiempoSegundos;
    } else {
      _modo = widget.modo;
      _nivel = _esContrarreloj ? 2 : 1;
      final pares = _esContrarreloj ? 8 : 6;
      _tablero = [for (var i = 0; i < pares; i++) ...[i, i]]..shuffle();
      _emparejadas = [];
      _movimientos = [];
      _etiquetas = [];
      _tiempo = 0;
    }
    _terminado = _emparejadas.length == _tablero.length ||
        (_esContrarreloj && _tiempo >= limiteContrarreloj);
    _reloj = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  @override
  void dispose() {
    _reloj?.cancel();
    super.dispose();
  }

  void _tick(Timer t) {
    if (_terminado) return;
    setState(() {
      _tiempo++;
      if (_esContrarreloj && _tiempo >= limiteContrarreloj) _terminar(false);
    });
  }

  void _terminar(bool gano) {
    _terminado = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(gano ? '¡Ganaste!' : 'Se acabó el tiempo'),
          content: Text('Puntuación: $_puntos'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
          ],
        ),
      );
    });
  }

  void _sonido() {
    if (Ajustes.sonido.value) {
      SystemSound.play(SystemSoundType.click);
      HapticFeedback.lightImpact();
    }
  }

  void _tocar(int i) {
    if (_bloqueado || _terminado || _emparejadas.contains(i) || _volteadas.contains(i)) return;
    setState(() => _volteadas.add(i));
    _sonido();
    if (_volteadas.length < 2) return;

    final a = _volteadas[0], b = _volteadas[1];
    _movimientos.add('$a-$b');
    if (_tablero[a] == _tablero[b]) {
      setState(() {
        _emparejadas.addAll([a, b]);
        _volteadas.clear();
        if (_emparejadas.length == _tablero.length) _terminar(true);
      });
    } else {
      _bloqueado = true;
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() {
          _volteadas.clear();
          _bloqueado = false;
        });
      });
    }
  }

  Future<void> _guardar() async {
    final msg = ScaffoldMessenger.of(context);
    try {
      final estado = GameState(
        modo: _modo,
        nivel: _nivel,
        puntuacion: _puntos,
        tiempoSegundos: _tiempo,
        tablero: _tablero,
        emparejadas: _emparejadas,
        movimientos: _movimientos,
        tema: Ajustes.tema.value,
        sonido: Ajustes.sonido.value,
        etiquetas: _etiquetas,
      );
      final archivo = await SaveService().guardar(estado, Ajustes.formato.value);
      msg.showSnackBar(SnackBar(content: Text('Guardada: ${archivo.uri.pathSegments.last}')));
    } catch (e) {
      msg.showSnackBar(SnackBar(content: Text('No se pudo guardar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tiempoTxt = _esContrarreloj
        ? 'Tiempo: ${max(0, limiteContrarreloj - _tiempo)} s'
        : 'Tiempo: $_tiempo s';
    return Scaffold(
      appBar: AppBar(
        title: Text(_esContrarreloj ? 'Contrarreloj' : 'Clásico'),
        actions: [
          IconButton(icon: const Icon(Icons.save), tooltip: 'Guardar partida', onPressed: _guardar),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('Puntos: $_puntos'),
                  Text(tiempoTxt),
                  Text('Intentos: ${_movimientos.length}'),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(builder: (context, c) {
                final horizontal = c.maxWidth > c.maxHeight;
                final columnas = horizontal ? max(2, _tablero.length ~/ 2) : (_tablero.length <= 12 ? 3 : 4);
                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columnas,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _tablero.length,
                  itemBuilder: (_, i) => _Carta(
                    visible: _emparejadas.contains(i) || _volteadas.contains(i),
                    emparejada: _emparejadas.contains(i),
                    icono: _simbolos[_tablero[i] % _simbolos.length],
                    onTap: () => _tocar(i),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _Carta extends StatelessWidget {
  final bool visible;
  final bool emparejada;
  final IconData icono;
  final VoidCallback onTap;
  const _Carta({required this.visible, required this.emparejada, required this.icono, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
        child: Container(
          key: ValueKey(visible),
          decoration: BoxDecoration(
            color: visible ? (emparejada ? cs.tertiaryContainer : cs.primaryContainer) : cs.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: visible
                ? Icon(icono, size: 36, color: cs.onPrimaryContainer)
                : Icon(Icons.help_outline, color: cs.onPrimary),
          ),
        ),
      ),
    );
  }
}