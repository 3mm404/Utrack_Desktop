# UTRACK Desktop 1.1.2

Interfaz Flutter para el motor local de audio. En producción muestra las zonas y los estados reportados por el motor, sin habitaciones, canciones, dispositivos ni métricas de ejemplo. El plano y la fotografía de equipo son ilustrativos.

La versión 1.1.2 reduce las reconstrucciones de pantalla durante la reproducción, conserva los catálogos sin cambios y muestra las canciones en páginas de 30 filas. En Windows utiliza un control de volumen/posición sin OverlayPortal y separa los nodos accesibles de las acciones para evitar los errores AXTree asociados a sliders y tooltips de Flutter. Conserva navegación por teclado y lector de pantalla.

Validación de esta entrega: análisis Flutter sin errores, 75 pruebas aprobadas (una omitida) y compilación Windows Release. Se distribuye con el Engine estable 0.8.9; los cambios pendientes de caché y descargas no forman parte de esta versión.

Esta entrega incluye Engine **0.8.9**, con reproducción de MP3 MPEG-1/2/2.5 en sus nueve frecuencias estándar, incluidas 44.1 y 48 kHz. El motor remuestrea en memoria sin FFmpeg y conserva el archivo original. La versión requerida está en `windows/engine/VERSION`; `build-windows.ps1` la comprueba al empaquetar.

Engine 0.8.9 reserva los canales ASIO configurados desde el inicio para agregar zonas durante la reproducción sin cambiar el formato PCM activo.

## Uso de producción en Windows

1. Ejecutar el paquete completo, con `engine.exe` junto a la aplicación.
2. Abrir Ajustes, ingresar servidor HTTPS y token, elegir la salida y guardar.
3. Iniciar motor. La conexión se confirma mediante sincronización, heartbeat y estados recientes.
4. Las zonas aparecen cuando el servidor las entrega al motor.

La aplicación permite configurar e iniciar/detener el motor. Con el motor 0.8.1 también permite pausa, reanudar, siguiente, anterior y reproducir una canción asignada desde Biblioteca. El motor 0.8.2 añade volumen local por zona mediante perilla y sliders. Canales, seek, aleatorio y repetición conservan sus controles deshabilitados. Ver docs/VOLUMEN_DESKTOP.md para alcance temporal y compatibilidad con el servidor.

```sh
flutter analyze
flutter test
flutter build windows --release --dart-define=UTRACK_TEST=false
```

El empaquetado necesita `windows/engine/engine.exe`. Salida: `build/windows/x64/runner/Release`; distribuir toda la carpeta.

## Documentación

| Documento | Contenido |
| --- | --- |
| [Agregar APIs y funciones](docs/AGREGAR_APIS_Y_FUNCIONES.md) | Registros centrales, paneles adicionales y flujo de integración |
| [Conexiones Desktop y APIs pendientes](docs/CONEXIONES_DESKTOP_Y_APIS_PENDIENTES.md) | Funciones conectadas, flujo y archivos de backend/Go/Flutter |
| [Producción](docs/PRODUCCION.md) | Configuración, datos disponibles y límites comprobados |
| [Arquitectura](docs/ARQUITECTURA.md) | Estructura y responsabilidades |
| [Integración](docs/INTEGRACION.md) | Flujo implementado y extensiones pendientes del protocolo |
| [Mantenimiento](docs/MANTENIMIENTO.md) | Compilación, actualizaciones y distribución |
| [Plan de trabajo](docs/ROADMAP.md) | Próximas entregas y responsables |
| [Registro](DESARROLLO_UI_POR_ETAPAS.md) | Historial de etapas y decisiones |

## Demostración explícita

```sh
flutter run -d chrome --dart-define=UTRACK_TEST=true
```

Solo esa bandera habilita el simulador. Web sin ella informa que el motor local requiere escritorio; no cambia silenciosamente a datos de ejemplo. macOS necesita preparar y validar su motor nativo antes de uso productivo.
