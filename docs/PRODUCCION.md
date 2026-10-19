# Producción: motor local y datos observados

> Actualización 19/10/2026: motor 0.8.1 conecta reproducción y canciones asignadas con Desktop. Las descripciones anteriores de reproducción solo desde servidor quedan sustituidas por [Conexiones Desktop y APIs pendientes](CONEXIONES_DESKTOP_Y_APIS_PENDIENTES.md). Volumen, seek y asignaciones siguen pendientes.

## Configuración inicial

Descomprimir el paquete completo de Windows. Abrir Ajustes e ingresar la URL base HTTPS del servidor y el token del equipo. No agregar rutas de endpoints a la URL base. Elegir salida del sistema (Oto) o el nombre exacto del driver ASIO instalado; guardar antes de iniciar.

El token se entrega al motor por entrada estándar. Flutter no lo persiste ni lo recupera para mostrarlo: el motor usa su almacenamiento protegido de Windows. Al editar una configuración existente, un token vacío conserva la credencial guardada. No incluir credenciales en capturas, repositorios o paquetes.

Iniciar motor y esperar sincronización y heartbeat. Una ejecución local activa por sí sola no confirma conexión al servidor. La aplicación muestra fallos de configuración, autenticación y sincronización mediante el controlador y la actividad. Al cerrar la aplicación se solicita detener su proceso hijo; no se instala un servicio independiente.

## Qué se muestra

| Campo | Origen / comportamiento |
| --- | --- |
| Zonas, nombre, playlist | Configuración sincronizada desde el servidor por el motor |
| Estado, volumen, modo y canción ID | Último reporte de zona del motor |
| Selección de zona | Estado local de navegación; conserva ID al reordenar zonas |
| Salida | Configuración local guardada; no es un catálogo de equipos detectados |
| Frecuencia y buffer ASIO | Valores configurados; no mediciones |
| Artista, título completo, duración, carátula | Pendientes de metadatos; se muestra el ID de canción cuando existe |
| Posición | Solo si el motor reporta `position_ms`; no avanza por temporizador local |
| CPU y latencia | No reportadas: campos preparados, sin estimaciones |
| Plano y fotografía | Ilustraciones de referencia; posiciones de zonas no representan ubicación física |

No se crean zonas cuando el reporte está vacío. Los datos retenidos tras una desconexión se señalan como no actualizados. El plano puede representar visualmente las zonas recibidas; no incorpora habitaciones ficticias a la configuración.

## Operaciones disponibles

- Inspeccionar, configurar, iniciar y detener el proceso local.
- Consultar estado y actividad; seleccionar una zona para ver su reporte.
- Volumen, habilitación, canales por zona, reproducción, seek, cola y modos: administrados por el servidor. El puente desktop no expone esos comandos y la UI no simula éxitos.

Oto utiliza la salida estéreo del sistema y mezcla las zonas. ASIO permite routing según los canales asignados por la configuración del motor. La selección de un driver no prueba que el hardware esté conectado ni que el audio sea audible.

## Compatibilidad y validación

Esta entrega utiliza el binario existente del motor 0.8.0, protocolo desktop 1. No modifica ni recompila el repositorio `music-engine`. Flutter consume `desktop-info`, `desktop-configure` y eventos de `run --desktop`; envía `stop` para terminar su proceso.

Las pruebas automatizadas comprueban mapeo, ausencia de datos demo, configuración, selección y controles deshabilitados. La prueba opt-in del proceso usa almacenamiento temporal y una dirección local sin servidor operativo. Aún debe comprobarse en la instalación real: autenticación, zonas recibidas, audio físico, routing, recuperación y cierre. No se ingresaron ni probaron las credenciales de tu servidor.

Para implementar los campos pendientes, ampliar primero los eventos del motor y su contrato: metadatos, duración, posición, dispositivos o mediciones reales. Después añadir parsing, mapeo y pruebas. Nunca completar un dato ausente con una muestra en producción.
