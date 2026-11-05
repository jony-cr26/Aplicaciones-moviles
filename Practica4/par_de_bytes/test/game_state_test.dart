import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:par_de_bytes/models/game_state.dart';

GameState crear({
  String modo = 'clasico',
  List<int>? tablero,
  List<int>? emparejadas,
  List<String>? movimientos,
  List<String>? etiquetas,
}) =>
    GameState(
      modo: modo,
      nivel: 1,
      puntuacion: 200,
      tiempoSegundos: 45,
      tablero: tablero ?? [0, 1, 2, 0, 1, 2],
      emparejadas: emparejadas ?? [0, 3],
      movimientos: movimientos ?? ['0-3', '1-2'],
      tema: 'guinda',
      sonido: true,
      etiquetas: etiquetas ?? ['prueba', 'favorita'],
    );

void esperarIgual(GameState a, GameState b) {
  expect(b.modo, a.modo);
  expect(b.nivel, a.nivel);
  expect(b.puntuacion, a.puntuacion);
  expect(b.tiempoSegundos, a.tiempoSegundos);
  expect(b.tablero, a.tablero);
  expect(b.emparejadas, a.emparejadas);
  expect(b.movimientos, a.movimientos);
  expect(b.tema, a.tema);
  expect(b.sonido, a.sonido);
  expect(b.etiquetas, a.etiquetas);
}

/// Espera un FormatoInvalido cuyo mensaje contenga [fragmento].
Matcher falla(String fragmento) => throwsA(
      isA<FormatoInvalido>().having((e) => e.mensaje, 'mensaje', contains(fragmento)),
    );

void main() {
  final Map<String, String Function(GameState)> ida = {
    'json': (s) => s.toJson(),
    'xml': (s) => s.toXml(),
    'txt': (s) => s.toTxt(),
  };
  final Map<String, GameState Function(String)> vuelta = {
    'json': GameState.fromJson,
    'xml': GameState.fromXml,
    'txt': GameState.fromTxt,
  };

  group('ida y vuelta', () {
    for (final f in ida.keys) {
      test('partida normal en $f', () {
        final original = crear();
        esperarIgual(original, vuelta[f]!(ida[f]!(original)));
      });
      test('partida sin movimientos, emparejadas ni etiquetas en $f', () {
        final original = crear(emparejadas: [], movimientos: [], etiquetas: []);
        esperarIgual(original, vuelta[f]!(ida[f]!(original)));
      });
    }
  });

  group('archivos vacíos', () {
    for (final f in vuelta.keys) {
      test('$f vacío', () => expect(() => vuelta[f]!(''), falla('vacío')));
      test('$f solo con espacios', () => expect(() => vuelta[f]!('   \n '), falla('vacío')));
    }
  });

  group('archivos incompletos o corruptos', () {
    test('JSON cortado', () {
      expect(() => GameState.fromJson('{"modo": "clasico", "nivel": 1'), falla('JSON mal formado'));
    });

    test('JSON que no es un objeto', () {
      expect(() => GameState.fromJson('[1,2,3]'), falla('estructura esperada'));
    });

    test('JSON sin puntuacion', () {
      final mapa = jsonDecode(crear().toJson()) as Map<String, dynamic>;
      mapa.remove('puntuacion');
      expect(() => GameState.fromJson(jsonEncode(mapa)), falla('Faltan campos'));
    });

    test('XML cortado', () {
      expect(() => GameState.fromXml('<partida><modo>clasico</modo>'), falla('XML mal formado'));
    });

    test('XML sin puntuacion', () {
      final xml = crear().toXml().replaceAll(RegExp(r'<puntuacion>.*</puntuacion>'), '');
      expect(() => GameState.fromXml(xml), falla('puntuacion'));
    });

    test('TXT sin la línea puntuacion', () {
      final txt = crear().toTxt().split('\n').where((l) => !l.startsWith('puntuacion=')).join('\n');
      expect(() => GameState.fromTxt(txt), falla('puntuacion'));
    });

    test('TXT con una línea inválida', () {
      expect(() => GameState.fromTxt('modo clasico'), falla('Línea inválida'));
    });

    test('TXT con valor no numérico', () {
      final txt = crear().toTxt().replaceFirst('nivel=1', 'nivel=abc');
      expect(() => GameState.fromTxt(txt), falla('"nivel" debe ser un número'));
    });
  });

  group('validaciones del modelo', () {
    test('modo desconocido', () => expect(() => crear(modo: 'otro'), falla('Modo de juego desconocido')));
    test('tablero impar', () => expect(() => crear(tablero: [0, 1, 0]), falla('impar')));
    test('emparejadas fuera del tablero', () {
      expect(() => crear(emparejadas: [99]), falla('fuera del tablero'));
    });
  });

  group('desdeArchivo', () {
    test('elige el formato por extensión (sin importar mayúsculas)', () {
      final original = crear();
      esperarIgual(original, GameState.desdeArchivo('partida.JSON', original.toJson()));
      esperarIgual(original, GameState.desdeArchivo('partida.xml', original.toXml()));
      esperarIgual(original, GameState.desdeArchivo('partida.txt', original.toTxt()));
    });

    test('extensión no soportada', () {
      expect(() => GameState.desdeArchivo('foto.png', 'x'), falla('Extensión no soportada'));
    });
  });
}