# Práctica 1: Instalación y funcionamiento de los entornos moviles

**Alumno:** Chavez Romero Jonathan  
**Boleta:** 2024630102  
**Grupo:** 7CV4  
**Materia:** Desarrollo de Aplicaciones Móviles  

---

## 1. Descripción de Herramientas Instaladas y Proyectos

### Herramientas Utilizadas
* **Java Development Kit (JDK):** Se utilizó la distribución Amazon Corretto (OpenJDK) para compilar y ejecutar programas en Java, así como para proporcionar el entorno de ejecución a Gradle y las herramientas del Android SDK.
* **Maven:** Herramienta de automatización y gestión de dependencias para proyectos software.
* **Git:** Sistema de control de versiones distribuido utilizado para dar seguimiento a los cambios en el código fuente del proyecto.
* **GitHub:** Plataforma de alojamiento para almacenar y gestionar el repositorio público de los proyectos desarrollados.
* **Flutter:** SDK de Google para el desarrollo de aplicaciones multiplataforma compiladas nativamente.
* **Node.js:** Entorno de ejecución de JavaScript fuera del navegador.
* **Docker:** Plataforma de contenedores utilizada para empaquetar y ejecutar servicios de forma aislada.
* **Android Studio:** Entorno de Desarrollo Integrado (IDE) oficial utilizado para la gestión de componentes del SDK de Android, herramientas de línea de comandos, emuladores y desarrollo del proyecto.

### Descripción de los Tres Proyectos Desarrollados
1. **Proyecto 1: Hola Mundo en XML (Android Tradicional):** Desarrollo de una aplicación móvil en Android utilizando vistas tradicionales estructuradas en archivos de diseño XML (`activity_main.xml`).
2. **Proyecto 2: Hola Mundo con Jetpack Compose:** Desarrollo de la interfaz utilizando el kit de herramientas moderno y declarativo de Android nativo basado en componentes Kotlin Composable.
3. **Proyecto 3: Hola Mundo con Flutter (`hola_mundo_flutter`):** Desarrollo de la aplicación multiplataforma utilizando el SDK de Flutter y Dart, implementando componentes como `MaterialApp`, `Scaffold`, `Card` y `ListTile` para presentar la información en una interfaz estilizada.
---

## 2. Instrucciones Paso a Paso: Instalación y Ejecución

* **Java Development Kit (JDK) & Maven:** Se descargó el instalador de Amazon Corretto (JDK) y los binarios de Apache Maven; se configuraron sus variables de entorno (`JAVA_HOME`, `MAVEN_HOME` y `PATH`) para posibilitar la compilación desde consola.
* **Git & GitHub:** Se instaló Git para Windows, se configuraron las credenciales del usuario y se vinculó la cuenta de GitHub para la gestión del repositorio remoto.
* **Node.js & Docker:** Se instalaron los paquetes ejecutables de Node.js (verificando con `node -v`).
* **Android Studio & Flutter SDK:** 
  1. Se instaló Android Studio junto con el SDK de Android, herramientas de línea de comandos y el emulador (Pixel 7 Pro).
  2. Se extrajo Flutter, agregando su carpeta `bin` al `PATH`.
* **Ejecución de los Proyectos:** 
  * **Proyectos XML y Jetpack Compose:** Se abrieron directamente en Android Studio y se ejecutaron en el emulador seleccionando sus configuraciones de Gradle correspondientes.
  * **Proyecto Flutter:** Se abrió el proyecto `hola_mundo_flutter`, se confirmó la ruta del SDK de Dart y se ejecutó en el emulador Pixel 7 Pro usando el botón **Run** de Android Studio o la terminal mediante `flutter run`.

  ## 3. Dificultades Encontradas y Soluciones

1. **Error de Configuración en el SDK de Dart dentro del IDE:**
   * **Dificultad:** Android Studio no detectaba automáticamente el SDK de Dart al abrir el proyecto, desplegando el aviso *Dart SDK is not configured*.
   * **Solución:** Se vinculó manualmente la carpeta `dart-sdk` ubicada en la caché del propio SDK de Flutter a través de las preferencias del IDE.

---

---

## 4. Tabla Comparativa de Métodos de Desarrollo

| Método | Lenguaje Principal | Facilidad de Desarrollo | Cantidad de Código | Diseño | Rendimiento |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **XML (Android Tradicional)** | XML + Java / Kotlin | Compleja (Separación estricta de UI en XML y lógica en controladores) | Alta (Múltiples archivos para layouts, IDs y vinculación de vistas) | Tradicional (Basado en vistas y estilos de sistema imperativos) | Nativo (Alto) |
| **Jetpack Compose** | Kotlin | Media-Alta (Desarrollo declarativo moderno en un solo lenguaje) | Media-Baja (Código conciso con componentes reutilizables) | Flexible (Basado en funciones *Composable* y previsualización en tiempo real) | Nativo (Alto) |
| **Flutter** | Dart | Alta (Recarga rápida *Hot Reload* y componentes listos para usar) | Baja (Unificada para múltiples plataformas en un solo archivo/Widget) | Personalizable (Motor de renderizado propio sin depender de componentes nativos) | Cercano a Nativo (Alto - Compilación AOT) |

---

---

## 5. Conclusión

Esta práctica me permitió comprobar la evolución del desarrollo móvil. La maquetación en **XML** me ayudó a entender las bases tradicionales de Android, aunque requiere más código y archivos. Con **Jetpack Compose** experimenté una forma nativa más moderna y limpia de programar la interfaz en Kotlin. Por último, **Flutter** me pareció la opción más ágil. En conclusión, la elección entre estas tecnologías depende de si el proyecto exige rendimiento nativo estricto o la eficiencia de un desarrollo multiplataforma.

---

---

## Referencias

[1] Google Developers, "Build UI with XML," Android Developers, 2023. [En línea]. Disponible en: https://developer.android.com/guide/topics/ui/declaring-layout.

[2] Google Developers, "Jetpack Compose documentation," Android Developers, 2024. [En línea]. Disponible en: https://developer.android.com/develop/ui/compose.

[3] Google, "Flutter documentation," Flutter Dev, 2024. [En línea]. Disponible en: https://docs.flutter.dev/.