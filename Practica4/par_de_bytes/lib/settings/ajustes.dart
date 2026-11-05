import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Ajustes {
  static final tema = ValueNotifier<String>('guinda'); // 'guinda' | 'azul'
  static final formato = ValueNotifier<String>('json'); // 'json' | 'xml' | 'txt'
  static final sonido = ValueNotifier<bool>(true);

  static Future<void> cargar() async {
    final p = await SharedPreferences.getInstance();
    tema.value = p.getString('tema') ?? 'guinda';
    formato.value = p.getString('formato') ?? 'json';
    sonido.value = p.getBool('sonido') ?? true;
  }

  static Future<void> persistir() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('tema', tema.value);
    await p.setString('formato', formato.value);
    await p.setBool('sonido', sonido.value);
  }
}