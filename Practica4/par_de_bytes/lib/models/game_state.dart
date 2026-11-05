import 'dart:convert';
import 'package:xml/xml.dart';

class FormatoInvalido implements Exception {
  final String mensaje;
  FormatoInvalido(this.mensaje);
  @override
  String toString() => mensaje;
}

class GameState {
  static const int version = 1;
  static const modosValidos = {'clasico', 'contrarreloj'};

  final String modo;
  final int nivel;
  final int puntuacion;
  final int tiempoSegundos;
  final List<int> tablero;        // índice de símbolo por celda (cada símbolo aparece 2 veces)
  final List<int> emparejadas;    // celdas ya resueltas
  final List<String> movimientos; // "3-7" = se voltearon las celdas 3 y 7
  final String tema;              // 'guinda' | 'azul'
  final bool sonido;
  final List<String> etiquetas;

  GameState({
    required this.modo,
    required this.nivel,
    required this.puntuacion,
    required this.tiempoSegundos,
    required this.tablero,
    required this.emparejadas,
    required this.movimientos,
    required this.tema,
    required this.sonido,
    required this.etiquetas,
  }) {
    _validar();
  }

  void _validar() {
    if (!modosValidos.contains(modo)) throw FormatoInvalido('Modo de juego desconocido: $modo');
    if (nivel < 1) throw FormatoInvalido('Nivel inválido');
    if (puntuacion < 0 || tiempoSegundos < 0) throw FormatoInvalido('Puntuación o tiempo negativos');
    if (tablero.isEmpty || tablero.length.isOdd) throw FormatoInvalido('Tablero vacío o con número impar de celdas');
    if (emparejadas.any((i) => i < 0 || i >= tablero.length)) {
      throw FormatoInvalido('Hay celdas emparejadas fuera del tablero');
    }
  }

  // ---------- JSON ----------
  String toJson() => const JsonEncoder.withIndent('  ').convert({
        'version': version,
        'modo': modo,
        'nivel': nivel,
        'puntuacion': puntuacion,
        'tiempoSegundos': tiempoSegundos,
        'tablero': tablero,
        'emparejadas': emparejadas,
        'movimientos': movimientos,
        'config': {'tema': tema, 'sonido': sonido},
        'etiquetas': etiquetas,
      });

  factory GameState.fromJson(String texto) {
    if (texto.trim().isEmpty) throw FormatoInvalido('El archivo está vacío');
    final dynamic d;
    try {
      d = jsonDecode(texto);
    } catch (_) {
      throw FormatoInvalido('JSON mal formado o incompleto');
    }
    if (d is! Map<String, dynamic>) throw FormatoInvalido('El JSON no tiene la estructura esperada');
    try {
      return GameState(
        modo: d['modo'] as String,
        nivel: d['nivel'] as int,
        puntuacion: d['puntuacion'] as int,
        tiempoSegundos: d['tiempoSegundos'] as int,
        tablero: (d['tablero'] as List).cast<int>(),
        emparejadas: (d['emparejadas'] as List).cast<int>(),
        movimientos: (d['movimientos'] as List).cast<String>(),
        tema: (d['config'] as Map)['tema'] as String,
        sonido: (d['config'] as Map)['sonido'] as bool,
        etiquetas: (d['etiquetas'] as List).cast<String>(),
      );
    } on FormatoInvalido {
      rethrow;
    } catch (_) {
      throw FormatoInvalido('Faltan campos o tienen un tipo incorrecto');
    }
  }

  // ---------- XML ----------
  String toXml() {
    final b = XmlBuilder();
    b.processing('xml', 'version="1.0" encoding="UTF-8"');
    b.element('partida', attributes: {'version': '$version'}, nest: () {
      void campo(String n, Object v) => b.element(n, nest: v.toString());
      campo('modo', modo);
      campo('nivel', nivel);
      campo('puntuacion', puntuacion);
      campo('tiempoSegundos', tiempoSegundos);
      campo('tablero', tablero.join(','));
      campo('emparejadas', emparejadas.join(','));
      campo('movimientos', movimientos.join(','));
      campo('tema', tema);
      campo('sonido', sonido);
      campo('etiquetas', etiquetas.join(','));
    });
    return b.buildDocument().toXmlString(pretty: true, indent: '  ');
  }

  factory GameState.fromXml(String texto) {
    if (texto.trim().isEmpty) throw FormatoInvalido('El archivo está vacío');
    try {
      final raiz = XmlDocument.parse(texto).rootElement;
      return GameState._desdeCampos({
        for (final e in raiz.childElements) e.name.local: e.innerText.trim(),
      });
    } on XmlException {
      throw FormatoInvalido('XML mal formado o incompleto');
    }
  }

  // ---------- TXT (clave=valor) ----------
  String toTxt() => [
        '# Par de Bytes - partida v$version',
        'modo=$modo',
        'nivel=$nivel',
        'puntuacion=$puntuacion',
        'tiempoSegundos=$tiempoSegundos',
        'tablero=${tablero.join(',')}',
        'emparejadas=${emparejadas.join(',')}',
        'movimientos=${movimientos.join(',')}',
        'tema=$tema',
        'sonido=$sonido',
        'etiquetas=${etiquetas.join(',')}',
      ].join('\n');

  factory GameState.fromTxt(String texto) {
    if (texto.trim().isEmpty) throw FormatoInvalido('El archivo está vacío');
    final campos = <String, String>{};
    for (final linea in texto.split('\n')) {
      final l = linea.trim();
      if (l.isEmpty || l.startsWith('#')) continue;
      final i = l.indexOf('=');
      if (i <= 0) throw FormatoInvalido('Línea inválida: "$l"');
      campos[l.substring(0, i)] = l.substring(i + 1);
    }
    return GameState._desdeCampos(campos);
  }

  // ---------- Común a XML y TXT ----------
  factory GameState._desdeCampos(Map<String, String> c) {
    String req(String k) => c[k] ?? (throw FormatoInvalido('Falta el campo "$k"'));
    int entero(String k) => int.tryParse(req(k)) ?? (throw FormatoInvalido('"$k" debe ser un número'));
    List<String> lista(String k) => req(k).isEmpty ? [] : req(k).split(',');
    List<int> enteros(String k) =>
        lista(k).map((s) => int.tryParse(s) ?? (throw FormatoInvalido('"$k" tiene valores no numéricos'))).toList();

    return GameState(
      modo: req('modo'),
      nivel: entero('nivel'),
      puntuacion: entero('puntuacion'),
      tiempoSegundos: entero('tiempoSegundos'),
      tablero: enteros('tablero'),
      emparejadas: enteros('emparejadas'),
      movimientos: lista('movimientos'),
      tema: req('tema'),
      sonido: req('sonido') == 'true',
      etiquetas: lista('etiquetas'),
    );
  }

  /// Útil para elegir formato desde la extensión del archivo.
  static GameState desdeArchivo(String nombre, String contenido) {
    final ext = nombre.split('.').last.toLowerCase();
    switch (ext) {
      case 'json': return GameState.fromJson(contenido);
      case 'xml': return GameState.fromXml(contenido);
      case 'txt': return GameState.fromTxt(contenido);
      default: throw FormatoInvalido('Extensión no soportada: .$ext');
    }
  }
}