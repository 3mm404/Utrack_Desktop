# Volumen del engine conectado a Desktop

Entrega 19/10/2026: motor 0.8.2, protocolo desktop 1 con capacidad opcional `volume`.

La perilla de la zona seleccionada, los sliders del plano y el slider del reproductor envían volumen al proceso Go activo. El slider del reproductor controla la zona seleccionada, no un volumen maestro del equipo. No se habilitan seek, canales, aleatorio, repetición ni edición de zonas. El botón independiente de mute conserva su comportamiento previo; se puede silenciar llevando el volumen a cero.

## Flujo

Flutter → EngineViewState.setVolume → EngineController.playback → ProcessEngineBridge → stdin JSON → Runtime.setDesktopVolume → player.SetVolume → resultado y snapshot Desktop.

```json
{"request_id":"id-unico","zone_id":"id-real","config_revision":3,"action":"volume","volume":50}
```

Go valida entero entre 0 y 100, zona asignada, revisión y disponibilidad de audio. Convierte el porcentaje a la escala 0–1 del reproductor. Solo registra un resultado exitoso si SetVolume no devuelve error. La capacidad independiente evita habilitar otras operaciones de zona. Un motor anterior mantiene deshabilitada la edición de volumen.

Flutter agrupa cambios durante 200 ms para no enviar una orden por cada movimiento. Conserva el último valor solicitado por zona y espera si hay otra orden pendiente. La UI identifica el volumen solicitado mientras espera confirmación; después vuelve al valor observado. Ante rechazo se muestra el error existente del controlador. No reintenta automáticamente una orden enviada.

## Persistencia y servidor

Es un ajuste local temporal, sin cambio de backend ni configuración persistida:

- Las sincronizaciones de la misma revisión conservan el volumen local.
- Una revisión nueva del servidor restablece el volumen de su configuración.
- Al reiniciar el motor se pierde el ajuste local.
- El snapshot Desktop muestra el volumen efectivo aplicado.
- El heartbeat conserva el volumen configurado por el servidor: el backend actual rechaza reportes cuyo volumen difiera de su snapshot. Por tanto, el panel del servidor no refleja este ajuste local como volumen configurado.

Para persistir o sincronizar este volumen con otros operadores habrá que ampliar el contrato/backend y aplicar una nueva revisión, o diferenciar volumen configurado y efectivo en los reportes. No basta con enviar el volumen local por heartbeat: hoy produciría un rechazo de validación.

## Archivos

Go: `cmd/agent/main.go` (versión), `internal/control/desktop.go` (capacidad, solicitud, aplicación y snapshot), `runtime.go` (overrides por revisión) y `playback.go` (conservación durante sincronización).

Flutter: `lib/controllers/engine_controller.dart` (parámetro), `lib/views/state/audio_view_state.dart` (capacidad), `engine_view_state.dart` (agrupación, cola y confirmación), y widgets `selected_zone_panel.dart`, `zone_map.dart`, `player_bar.dart`.

## Validación de esta entrega

Por petición expresa del usuario no se ejecutan pruebas ni validación auditiva. Solo se compilan Go y Flutter en modo release de producción. Las pruebas registradas en documentos anteriores corresponden a entregas anteriores y no verifican este cambio de volumen.

Usar el paquete completo nuevo con motor 0.8.2; conservar la versión anterior para poder volver a ella. Pendiente comprobar el volumen con servidor y hardware reales.
