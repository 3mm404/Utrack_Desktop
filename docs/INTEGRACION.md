# Preparación de integración — Etapa 10

## 1. Qué se entrega y qué falta

Se declara `lib/views/contracts/audio_ui_port.dart`, una frontera **propuesta de presentación**. No es un protocolo de red, no reemplaza `EngineBridge`, no tiene implementación ni está conectada a la UI. Los widgets continúan usando `ZonePreviewState`. No se añade un backend ficticio que aparente una integración real.

El objetivo es acordar el vocabulario de pantallas y comandos antes de desarrollar un adaptador. Cualquier trabajo en servicios, motor o backend requiere un alcance posterior explícito.

## 2. Contrato tipado

| Tipo | Significado |
| --- | --- |
| `AudioUiPort` | Expone un `ValueListenable<AudioUiSnapshot>` y recibe comandos asíncronos |
| `AudioUiSnapshot` | Estado observado completo: origen, conexión, fase del motor, revisión, fecha, zonas, salidas, capacidades, solicitudes pendientes y métricas |
| `UiZoneSnapshot` | ID estable, nombre, volumen, habilitación, reproducción, canales, pista, posición y modos |
| `UiTrackSnapshot` | ID, título, artista, duración y URI opcional de carátula |
| `UiOutputSnapshot` | ID, nombre, disponibilidad, driver, frecuencia y buffer |
| `AudioUiCommand` | Intención tipada con `requestId` y revisión esperada opcional |
| `UiCommandResult` | Aceptación o rechazo de una solicitud; aceptar no equivale a confirmar aplicación |

Comandos definidos: motor iniciado/detenido, volumen de zona, habilitación, reproducción/pausa, selección de pista, posición, canales, salida y modos de reproducción. Se envían valores explícitos, por ejemplo `playing: false`, en lugar de un toggle ambiguo al reintentar.

```dart
final request = UiSetVolume(
  requestId: 'identificador-unico-de-la-solicitud',
  zoneId: 'identificador-estable-de-zona',
  volume: 65,
  expectedRevision: 12,
);
// El adaptador futuro despachará request. Hoy no existe una instancia de AudioUiPort.
```

Las colecciones del snapshot son copias no modificables. Los contratos no contienen token, ruta de ejecutable ni detalles de transporte. No serializan JSON: esa conversión pertenecerá al adaptador.

## 3. Semántica que debe conservar el adaptador futuro

- `revision` ordena snapshots de una sesión; no es versión de app ni versión de protocolo. Acordar cómo identificar una sesión/reinicio del motor y reiniciar revisiones: el contrato inicial todavía no incluye `sessionId`.
- `observedAt` indica cuándo se observó el estado. Para frescura utilizar reloj monotónico local en el adaptador; no comparar sin más el reloj del servidor con el cliente.
- `origin` distingue muestras simuladas de datos del motor. Mantener esta distinción visible.
- `connection` es independiente de la fase del motor: un motor local puede seguir reproduciendo aunque falte conexión al servidor.
- `enabled` no garantiza reproducción ni salida audible. `playback` distingue idle/buffering/playing/paused/failed.
- Volumen utiliza escala UI 0–100; posición y duración utilizan `Duration`. Frecuencia: Hz; buffer: frames; latencia: ms; CPU: porcentaje.
- Métrica `null` significa desconocida; cero es un dato observado. No sustituir desconocido por cero.
- `capabilities` vacías significan solo lectura. Deshabilitar acciones no admitidas antes de enviarlas, pero validar también en el receptor.
- Validar finitud, límites, IDs, duraciones y enum soportados en tiempo de ejecución. Los tipos o asserts de Dart no sustituyen esa validación.
- La selección visual sigue siendo estado local; no envía un comando al motor al cambiar de habitación.

## 4. Solicitud, confirmación y error

Flujo propuesto, todavía no implementado:

1. La UI produce un ID único y un comando con el estado deseado.
2. El presentador verifica capacidad y disponibilidad; el adaptador valida y despacha.
3. La solicitud aparece como pendiente; el control muestra espera y limita duplicados.
4. Una aceptación indica recepción/validación. Solo un snapshot o evento correlacionado confirma el resultado aplicado.
5. Rechazo, desconexión o timeout elimina la espera y muestra error recuperable. No marcar Conectado o Reproduciendo por anticipado.

Errores previstos: unsupported, invalidInput, unavailable, busy, staleRevision, timeout y failed. No reutilizar silenciosamente una respuesta de otra solicitud. El identificador no implementa idempotencia por sí mismo: el receptor deberá conservar/deduplicar solicitudes si se acuerda ese comportamiento. Definir los plazos por operación; un timeout de UI no prueba que el motor no aplicó el comando.

Para sliders, agrupar cambios durante el arrastre y confirmar el último valor, evitando un comando por cada frame. Conservar estado observado y valor deseado por separado; si se permite actualización optimista, diseñar rollback y avisos.

## 5. Protocolo existente y brechas comprobadas

`ProcessEngineBridge` actualmente dispone de:

- `desktop-info`: consulta JSON de inspección.
- `desktop-configure`: envía configuración y token por entrada estándar.
- `run --desktop`: inicia el proceso observado.
- `stop` por entrada estándar: solicita la parada.
- Eventos consumidos por el controlador: log, connection, status y exit. `EngineController` exige `protocol == 1` y usa sync/heartbeat más frescura de snapshot para su estado conectado.

No hay métodos tipados actuales de volumen, seek, play/pause de zona, pista, dispositivos o modos de reproducción en `EngineBridge`. El contrato nuevo no hace que esos comandos existan. Tampoco están verificados catálogo, metadatos completos, carátulas, CPU o latencia real en este flujo. Deben especificarse y probarse antes de habilitar controles en producción.

`ProcessEngineBridge` trabaja con mapas dinámicos y conversiones directas. El adaptador futuro necesita validar esquemas, tolerar campos opcionales, tratar eventos desconocidos y descartar mensajes inválidos sin tumbar la UI. Las credenciales y datos sensibles no deben entrar en snapshots ni logs de pantalla.

## 6. Secuencia recomendada de conexión

1. Acordar con el motor capacidades y esquema de eventos; documentar ejemplos reales anonimizados y versiones compatibles.
2. Implementar un adaptador solo lectura en una etapa nueva. Mapear IDs reales, estados, frescura y errores al contrato.
3. Inyectar el puerto desde composición; separar preview y producción explícitamente. Mantener una ruta de regreso a la vista anterior durante validación.
4. Migrar un widget por vez a un presentador que lea snapshots, sin llamadas de proceso desde widgets.
5. Agregar comandos uno por vez, empezando por una operación verificable. Probar aceptación, confirmación, rechazo, duplicados, timeout y reconexión.
6. Incorporar estado inicial desconocido, cero zonas, desaparición de zona/dispositivo, sesión reiniciada y cambios concurrentes desde el servidor.
7. Validar con audio físico antes de etiquetar la integración como operativa.

No implementar un adaptador que traduzca toda intención a éxito local. Si una capacidad no existe, la UI deberá indicarlo.

## 7. Plataformas y propiedad

Escritorio podrá usar un adaptador de proceso local, con diferencias de drivers y empaquetado por sistema. Web necesitaría un servicio remoto o un puente local autorizado, con un diseño propio de autenticación/orígenes y transporte; el navegador no puede ejecutar `engine.exe` ni utilizar ASIO directamente. No se ha implementado esa arquitectura.

La raíz de composición crea el futuro adaptador y lo libera una vez; widgets solo se suscriben. Cancelar streams, timers y solicitudes pendientes al cerrar. Definir si cerrar Flutter detiene el audio o deja un servicio funcionando: el flujo anterior intenta detenerlo, pero la política futura aún es una decisión de producto.

Los contratos son una propuesta inicial: antes de congelarlos falta decidir colas, anterior/siguiente autoritativos, repetición global o por pista, fuente por zona, multisalida, identificación de sesión y conciliación de cambios remotos.
