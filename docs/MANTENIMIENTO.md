# Mantenimiento, compilación y actualizaciones

> Producción usa EngineViewState con datos reales. Consultar PRODUCCION.md para capacidades y campos pendientes. El simulador requiere UTRACK_TEST=true.

Esta guía describe tareas futuras y comandos de trabajo; no instala un actualizador ni publica versiones. Validar el entorno y la compatibilidad antes de cada entrega.

## 1. Entorno reproducible

La resolución local inspeccionada registra Flutter 3.47.7 y Dart 3.13.5; `pubspec.yaml` permite Dart `^3.12.1` y la app declara `0.1.0+1`. Estas cifras describen el entorno usado, no un compromiso de soporte. Falta fijar y registrar la versión exacta de SDK en CI/equipo.

Mantener `pubspec.lock` en control de versiones y registrar versiones de Flutter, herramientas nativas y motor en cada release. `.dart_tool` se regenera. Antes de desarrollar:

```sh
flutter --version
flutter doctor -v
flutter pub get
flutter analyze
flutter test
```

En esta máquina Flutter se localizó en `C:/Develop/SDK-FLUTTER/flutter/bin`; si no está en PATH, invocar su ruta completa o configurar PATH. La [guía oficial de PATH](https://docs.flutter.dev/install/add-to-path) explica la configuración por sistema.

## 2. Pruebas y evidencias

| Validación | Qué cubre | Qué no demuestra |
| --- | --- | --- |
| Análisis Dart | Tipos, imports y reglas de estilo | Audio o rendimiento real |
| `flutter test` | Adaptador real, ausencia de demos, widgets, controlador y preview con fakes | Drivers físicos ni todo el protocolo real |
| Harness visual | Cinco tamaños, capturas, texto ampliado y movimiento reducido | Lectores de pantalla reales o fidelidad en cada SO |
| Integración de proceso opt-in | Proceso local existente y ciclo de vida | Reproducción correcta en todas las interfaces |
| QA físico pendiente | Audio, routing, recuperación, carga y latencia medidos | Debe diseñarse y ejecutarse por plataforma |

```sh
flutter test test/ui_visual_review_test.dart
```

Capturas: `build/previews/stage9-*.png`. El harness intenta cargar Segoe UI desde Windows si existe; para comparar píxeles entre equipos/CI hay que fijar una fuente de prueba redistribuible y el entorno de renderizado. No hay goldens de producción congelados.

La integración `process_engine_bridge_test.dart` se omite salvo Windows con `ENGINE_BRIDGE_TEST=1` y binario preparado. En PowerShell, después de preparar un motor de prueba:

```powershell
$env:ENGINE_BRIDGE_TEST = '1'
flutter test test/process_engine_bridge_test.dart
Remove-Item Env:ENGINE_BRIDGE_TEST
```

No ejecutar esa integración sobre una instalación operativa; usar datos temporales y un ejecutable de prueba controlado.

Para rendimiento, usar profile en el destino, medir frames, CPU/memoria y crecimiento tras navegación/reconexión. La [documentación de profiling de Flutter](https://docs.flutter.dev/perf/ui-performance) explica las herramientas; las capturas de widgets no son un benchmark.

## 3. Compilación por plataforma

### Web: demostración actual

```sh
flutter build web --release --dart-define=UTRACK_TEST=true
```

Publicar el contenido completo de `build/web` en un hosting estático elegido posteriormente. Probar rutas, base URL si se sirve en una subcarpeta, caché tras actualización y carga de assets en el hosting final. El resultado no controla un proceso local. La [guía oficial de web](https://docs.flutter.dev/deployment/web) documenta los artefactos y opciones de compilación.

### Windows

Se requieren herramientas nativas de Visual Studio para desarrollo desktop, además de Flutter. Revisar la [configuración oficial de Windows](https://docs.flutter.dev/platform-integration/windows/setup).

`windows/CMakeLists.txt` copia obligatoriamente `windows/engine/engine.exe`; el binario está preparado localmente y está ignorado por Git. Esto también afecta un build Flutter con modo test: la bandera cambia la ejecución, no elimina esa regla CMake.

`build-windows.ps1` compila el motor desde el repositorio hermano `../music-engine` mediante Go y luego llama `flutter build windows --release`. No se ejecutó ni modificó ese script. Para esta entrega se reutiliza el motor 0.8.0 existente (protocolo 1), sin recompilar Go. Registrar y validar la versión al sustituirlo.

Con un binario compatible ya preparado por el responsable del motor:

```sh
flutter build windows --release --dart-define=UTRACK_TEST=false
```

La salida habitual está en `build/windows/x64/runner/Release`. Distribuir el directorio completo, no solo el ejecutable: motor, DLL y assets son parte del paquete. Falta elegir instalador, identidad y firma. La [guía de distribución Windows](https://docs.flutter.dev/deployment/windows) describe las opciones de empaquetado.

### macOS

Desde un Mac con Xcode/Flutter configurados:

```sh
flutter build macos --release --dart-define=UTRACK_TEST=true
```

Salida: `build/macos/Build/Products/Release`. El runner aún usa identidad de ejemplo `com.example.utrackV1`. Antes de distribuir: identidad propia, iconos, firma, notarización o proceso de tienda según el canal, arquitectura elegida y QA nativo. Consultar la [guía oficial macOS](https://docs.flutter.dev/deployment/macos).

Para producción real falta motor macOS compatible, permisos y empaquetado en `Contents/MacOS/engine`. El entitlement Release inspeccionado activa App Sandbox y no declara acceso de red saliente; auditar sandbox, red, procesos hijos y rutas de datos para la arquitectura final. El soporte ASIO mostrado en el preview es un ejemplo Windows, no un driver macOS.

## 4. Cuatro tipos distintos de actualización

| Tipo | Qué cambia | Responsable sugerido | Validación mínima |
| --- | --- | --- | --- |
| SDK/dependencias | Flutter, Dart, paquetes y herramientas nativas | Flutter/CI | Analizar, probar, capturar y compilar cada destino |
| App | UI, assets, presentadores y configuración visual | Flutter/release | Regresión, versión/build y paquete completo |
| Motor | Protocolo, audio, drivers y recuperación | Equipo motor | Compatibilidad UI/motor, pruebas de audio e integración |
| Datos | Configuración, caché, preferencias y secretos | Dueño de cada almacenamiento | Backup, migración, recuperación y compatibilidad de lectura |

No actualizar estas cuatro cosas simultáneamente sin una matriz de compatibilidad y un plan de retorno.

### Actualizar Flutter y paquetes

En una rama/entorno aislados: registrar versión actual, revisar cambios incompatibles y ejecutar primero `flutter pub outdated`. Probar una actualización de SDK y otra de paquetes por separado; revisar `pubspec.lock` y cambios generados. `flutter upgrade` cambia el SDK del canal actual; `flutter pub upgrade` cambia resoluciones de paquetes. No ejecutarlos automáticamente en cada build. La [guía oficial de actualización](https://docs.flutter.dev/install/upgrade) detalla esas diferencias.

Tras la actualización: análisis, pruebas, capturas comparadas, builds por plataforma y prueba manual de ejecución/cierre. Mantener disponible el SDK anterior y artefactos aprobados. No instalar paquetes mayores solo para quitar avisos de versiones disponibles.

## 5. Actualizaciones para usuarios finales: pendiente

No existe un actualizador automático, feed de versiones ni canal beta/stable. Primer paso recomendado: paquete completo versionado, firmado por el canal elegido y actualización manual documentada. Automatizar después de validar ese proceso.

Para un futuro actualizador se necesita diseñar:

1. Manifest de versión con plataforma/arquitectura, versión de app, motor compatible, protocolo y esquema de datos.
2. Descarga autenticada según el canal y verificación de firma/integridad antes de ejecutar. Un hash publicado junto al archivo no reemplaza una firma confiable.
3. Consulta de actualizaciones separada de la descarga e instalación; mostrar cambios e impacto sobre audio.
4. Directorio temporal, espacio libre, validación y sustitución controlada; no sobrescribir un ejecutable en uso.
5. Ventana de mantenimiento: parar audio/proceso de forma acordada, instalar y hacer comprobación de arranque.
6. Copia recuperable de la versión anterior y migraciones reversibles o estrategia explícita para datos no reversibles.
7. Si falla validación/arranque, restaurar versión compatible y notificar. No reiniciar en bucle ni degradar silenciosamente.
8. Canales piloto/stable, despliegue gradual y posibilidad de retirar una actualización defectuosa.

Web requiere su propia política de caché y sesiones/versiones; no utilizar un actualizador de ejecutables para el navegador. Ninguna de estas funciones se implementó en Etapa 10.

## 6. Checklist de release

- Definir si es demo o producción; comprobar banderas y que los datos simulados estén rotulados.
- Aumentar `version` de la app y registrar versión independiente de motor/protocolo; conservar compatibilidad mínima y máxima probada.
- Analizar y probar; justificar tests omitidos. Ejecutar integración local cuando se distribuye el motor.
- Compilar en el SO destino; probar instalación limpia y actualización desde la versión anterior soportada.
- Probar equipo sin motor, driver ausente, salida desconectada, pérdida de red y cierre durante operación.
- Revisar credenciales fuera de logs/paquetes, firma, assets, rutas y licencias de recursos/dependencias.
- Preparar release notes, paquete completo, instrucciones de retorno y responsable de soporte.
- Distribuir solo después de aprobación de producto y QA; registrar evidencia por plataforma.

## 7. Operación y soporte futuros

Diseñar logs rotativos con límites y redacción de tokens; diagnóstico exportable con consentimiento; IDs de solicitud y versiones; estados de conexión separados del motor; contador de errores/reconexión. No incluir credenciales o rutas sensibles en reportes públicos.

Las rutas reales de datos deben provenir del motor/adaptador y del SO, no de `C:/...` escrito en la UI. Definir retención de caché, capacidad de disco, copias de configuración y qué borra una reinstalación. UI y motor deben acordar la propiedad de cada archivo y la política de cierre/arranque automático.
