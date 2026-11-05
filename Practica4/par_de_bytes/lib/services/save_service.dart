import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/game_state.dart';

class PartidaGuardada {
  final String nombre;
  final String ruta;
  final int tamano;
  final DateTime modificada;
  final GameState? estado; // null si el archivo está dañado
  final String? error;

  PartidaGuardada({
    required this.nombre,
    required this.ruta,
    required this.tamano,
    required this.modificada,
    this.estado,
    this.error,
  });

  String get formato => nombre.split('.').last;
}

class SaveService {
  Future<Directory> _carpeta() async {
    final base = await getApplicationDocumentsDirectory(); // almacenamiento privado
    final dir = Directory('${base.path}/partidas');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<File> guardar(GameState estado, String formato) async {
    final String contenido;
    switch (formato) {
      case 'json':
        contenido = estado.toJson();
      case 'xml':
        contenido = estado.toXml();
      case 'txt':
        contenido = estado.toTxt();
      default:
        throw FormatoInvalido('Formato no soportado: $formato');
    }
    final dir = await _carpeta();
    final destino = File('${dir.path}/partida_${DateTime.now().millisecondsSinceEpoch}.$formato');
    final temporal = File('${destino.path}.tmp');
    await temporal.writeAsString(contenido, flush: true);
    return temporal.rename(destino.path);
  }

  Future<List<PartidaGuardada>> listar() async {
    final dir = await _carpeta();
    final resultado = <PartidaGuardada>[];
    await for (final e in dir.list()) {
      if (e is! File) continue;
      final nombre = e.uri.pathSegments.last;
      if (!RegExp(r'\.(json|xml|txt)$').hasMatch(nombre)) continue;
      final info = await e.stat();
      GameState? estado;
      String? error;
      try {
        estado = GameState.desdeArchivo(nombre, await e.readAsString());
      } on FormatoInvalido catch (x) {
        error = x.mensaje;
      } catch (_) {
        error = 'No se pudo leer el archivo';
      }
      resultado.add(PartidaGuardada(
        nombre: nombre,
        ruta: e.path,
        tamano: info.size,
        modificada: info.modified,
        estado: estado,
        error: error,
      ));
    }
    resultado.sort((a, b) => b.modificada.compareTo(a.modificada));
    return resultado;
  }

  Future<void> eliminar(String ruta) async {
    final f = File(ruta);
    if (await f.exists()) await f.delete();
  }
}