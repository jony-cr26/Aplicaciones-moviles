import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'settings/ajustes.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Ajustes.cargar();
  runApp(const ParDeBytesApp());
}

class ParDeBytesApp extends StatelessWidget {
  const ParDeBytesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: Ajustes.tema,
      builder: (context, tema, _) => MaterialApp(
        title: 'Par de Bytes',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.construir(tema, Brightness.light),
        darkTheme: AppTheme.construir(tema, Brightness.dark),
        themeMode: ThemeMode.system, // sigue el modo claro/oscuro del sistema
        home: const HomeScreen(),
      ),
    );
  }
}