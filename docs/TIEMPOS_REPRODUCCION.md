# Tiempo y duración desde el motor Go

Motor 0.8.4. Desktop muestra tiempo transcurrido y duración de la canción seleccionada sin esperar nuevas APIs del backend.

## Medición

`internal/player/progress.go` cuenta bytes PCM entregados al mixer/salida. MP3 se decodifica a estéreo int16: cuatro bytes por frame. Posición = bytes entregados / (frecuencia × 4). Duración = longitud PCM del decodificador / (frecuencia × 4). El mezclado mono conserva ese tamaño de frame.

El contador pertenece a cada pista/zona y usa acceso atómico porque el backend lee desde otro hilo. Al pausar, el mixer deja de consumir esa zona; reanudar continúa el contador. Stop explícito devuelve la posición a cero; una canción nueva reinicia la medición. Al finalizar naturalmente se conserva el último valor leído. Si la duración es desconocida permanece ausente, sin inventarla.

La posición indica PCM entregado al backend, no la muestra exacta que está sonando en el altavoz: los buffers del mixer/driver pueden producir un pequeño adelanto visual. No es una medición de latencia.

## Descargas

El contenido HTTPS ya se verifica y carga en memoria. `decoder.OpenBytes` conserva io.Seeker mediante un reader cerrable para que go-mp3 pueda calcular su longitud. El wrapper anterior io.NopCloser ocultaba Seek. No se añade una descarga secundaria ni se exponen URLs firmadas a Flutter.

## Flujo público

Player.State → DesktopZone.position_ms/duration_ms → evento status por stdout → EngineController → ZoneStatus → EngineViewState → PlayerBar.

Los campos son opcionales, en milisegundos, dentro de las zonas públicas del evento Desktop. No se añade duration_ms al reporte heartbeat de Laravel; el backend no se modifica. Motores anteriores siguen mostrando guiones si no entregan tiempos. Flutter convierte posición a segundos y duración a segundos redondeados hacia arriba para presentar el final de la pista.

La actualización sigue la frecuencia de snapshots del motor, aproximadamente un segundo. No se agrega un temporizador de avance ficticio en Flutter. La barra permanece de solo lectura: seek no se ha conectado.

## Archivos

Go: `internal/player/progress.go`, `player.go`, `internal/decoder/mp3.go`, `https.go`, `internal/control/desktop_protocol.go`, `desktop.go`, `cmd/agent/main.go`.

Flutter: `lib/models/engine_status.dart`, `lib/views/state/engine_view_state.dart`, `lib/views/widgets/player_bar.dart`.

## Validación

Compilación Go y Windows release, análisis Dart. Por instrucción del usuario no se ejecutaron pruebas ni reproducción con hardware. Verificar posteriormente: duración en MP3 real, avance, pausa/reanudar, stop, cambio de canción, fin de pista y varias zonas. Reemplazar el paquete completo: el motor anterior no emite los nuevos campos.
