# Integración implementada y extensiones pendientes

> Actualización 19/10/2026: motor 0.8.1 conecta reproducción y canciones asignadas con Desktop. Las descripciones anteriores de reproducción solo desde servidor quedan sustituidas por [Conexiones Desktop y APIs pendientes](CONEXIONES_DESKTOP_Y_APIS_PENDIENTES.md). Volumen, seek y asignaciones siguen pendientes.

## Flujo actual

`EngineDashboard` crea `EngineViewState` cuando `UTRACK_TEST=false`. Los widgets consumen `AudioViewState`; el adaptador escucha `EngineController`, que utiliza `ProcessEngineBridge` para comunicarse con el motor local.

`ZonePreviewState` y `DemoEngineBridge` se reservan para test explícito. Producción no hereda sus zonas, canciones, dispositivos, temporizadores ni métricas.

## Protocolo comprobado

- `desktop-info`: versión, protocolo, configuración, drivers y proceso activo.
- `desktop-configure`: configuración y token por stdin.
- `run --desktop`: eventos JSON `connection`, `status`, `log` y salida de proceso.
- `stop` por stdin: parada del proceso hijo.

`EngineController` exige protocolo 1. Conectado requiere sincronización, heartbeat y snapshot reciente. La UI conserva selección por ID, acepta cero zonas y muestra ausencia de actualización. Los mensajes inválidos producen error recuperable en lugar de derribar la pantalla.

El reporte actual proporciona IDs de zona/playlist/canción, estado, volumen, modo, salida y error. `position_ms` es opcional y actualmente no se rellena en el reporte de audio del motor inspeccionado. No se reciben títulos completos, artistas, duraciones, carátulas, CPU o latencia.

## Límites de control

El pipe desktop no recibe comandos de volumen, reproducción, canales, pista, seek o modos por zona. El servidor sigue siendo la autoridad. La UI deshabilita esas operaciones; `AudioViewState` las rechaza si se invocan sin soporte.

No reutilizar los comandos de la consola independiente como si pertenecieran al proceso autenticado desktop. Tampoco inventar endpoints de administración del servidor.

## Evolución

1. Acordar con motor/backend capacidades, autorización y semántica de cada comando.
2. Añadir identificación de sesión, solicitud y resultado aplicado cuando sea necesario.
3. Validar esquema, límites, unidades, revisiones y errores en ambos extremos.
4. Separar valor observado de intención pendiente; una aceptación no confirma aplicación.
5. Cubrir rechazo, desconexión, duplicados, timeout, concurrencia y reinicio.
6. Habilitar cada control solo cuando el protocolo lo soporte y se haya verificado con audio físico.

`lib/views/contracts/audio_ui_port.dart` conserva la propuesta de Etapa 10 para futuros comandos/snapshots. No es el contrato implementado por esta entrega. La frontera utilizada actualmente es `AudioViewState` y su adaptador `EngineViewState`.

Web sin bandera test informa indisponibilidad del motor local. Necesita una arquitectura remota propia para operar; no puede ejecutar `engine.exe`. macOS requiere empaquetado nativo y validación independiente.

Ver [Producción](PRODUCCION.md) para operación y matriz de datos disponibles.
