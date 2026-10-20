# Detener una zona desde Desktop

Entrega 20/10/2026, motor 0.8.3. El botón cuadrado «Detener zona» aparece en el reproductor y apunta al ID de la zona seleccionada.

## Conexión

PlayerBar → EngineViewState.stopPlayback → controlador/EngineApiRequest → ProcessEngineBridge → solicitud JSON action=stop → catálogo Go → execute/supersede → Player.Stop → command_result + snapshot observado.

El handler de audio ya existía: esta entrega registra la capacidad local y conecta el control de Flutter. No modifica Laravel ni incorpora endpoints nuevos.

## Dos paradas distintas

- JSON con `action: stop`, ID de zona y revisión: detiene esa zona, cancela su carga pendiente y conserva el motor y las demás zonas.
- Línea de texto `stop` por stdin: termina el motor completo. Sigue siendo el mecanismo de «Detener motor» y cierre de la aplicación.

Go valida la zona y revisión y confirma el resultado. La UI conserva el estado observado; no marca una zona como detenida por anticipado. Con un motor anterior que no anuncie stop, el botón permanece deshabilitado.

Se admite enviar Detener zona mientras una reproducción está cargando. Se bloquean paradas duplicadas mientras espera confirmación. No cambia las asignaciones del servidor ni su configuración persistida. Una orden remota posterior puede volver a iniciar reproducción.

## Archivos

- Go: `internal/control/desktop_operations.go`, registro de stop; `cmd/agent/main.go`, versión 0.8.3. Se reutilizan los handlers de playback existentes.
- Flutter: `lib/integrations/engine_api/engine_api_catalog.dart`, enum de operación; `lib/controllers/engine_controller.dart`, prioridad de parada durante carga; `lib/views/state/audio_view_state.dart` y `engine_view_state.dart`, intención y capacidad; `lib/views/widgets/player_bar.dart`, botón.
- La sección Funciones y ajustes adicionales muestra automáticamente Detener zona cuando el motor anuncia su capacidad.

## Validación

Por instrucción vigente no se ejecutan pruebas ni audio físico. Se compila Go y se analiza/compila Flutter. Comprobar posteriormente en la instalación real la parada de una zona reproduciendo o cargando y que otras zonas continúen. No se ingresaron credenciales del servidor.
