# Plan de trabajo posterior y responsabilidades de entrega

## 1. Punto de partida

Las etapas 0–9 entregaron una UI de pruebas; Etapa 10 añade contratos propuestos y documentación. Esto no equivale a un producto de audio integrado. El orden de este documento es una propuesta para próximos alcances, no autorización para ejecutarlos automáticamente.

Estados usados: **hecho** = presente en el código; **simulado** = solo presentación; **pendiente** = requiere desarrollo o validación.

| Área | Estado actual | Trabajo que falta |
| --- | --- | --- |
| Diseño, layout y accesibilidad básica | Hecho; revisión visual y pruebas de widgets | QA nativo, lectores de pantalla, DPI y rendimiento en hardware |
| Plano y zonas | Simulado | IDs reales, planos configurables, sincronización y estados vacíos/error |
| Zona seleccionada y volumen | Simulado | Comandos soportados, confirmación, permisos y manejo de conflictos |
| Reproductor | Simulado | Cola y tiempo autoritativos, audio real desde motor, buffering/errores |
| Salidas y métricas | Simulado | Enumeración, drivers, cambio real, métricas medidas |
| Vista anterior de motor | Bridge de proceso existente | Probar protocolo completo, instalación local y fallos reales |
| Frontera UI | Contrato Dart propuesto | Acuerdo de protocolo, adaptador, presentador e inyección |
| Biblioteca y playlists | Placeholder | Catálogo, búsqueda, metadatos, permisos, vacíos y paginación |
| Persistencia de UI | No implementada | Preferencias, selección/volumen deseado, migraciones y recuperación |
| macOS | Runner generado | Motor, permisos, firma, empaquetado y QA en Mac |
| Web | Preview | Elegir si será demo o control remoto; diseñar arquitectura si controla equipos |
| Windows instalable | Script/CMake existentes | Preparar motor, instalador, firma y validación limpia |
| Actualizaciones | No implementadas | Primero entrega manual versionada; luego actualizador seguro |

## 2. Prioridades y criterios de cierre

### P0 — Decisiones y base reproducible

**Responsables sugeridos:** producto, Flutter y motor.

- Definir destino comercial: Windows primero, alcance de macOS y papel de web.
- Decidir si el servidor o el equipo local es autoridad de cada operación y si cerrar Flutter detiene el audio.
- Fijar versión de Flutter en CI y documentar la combinación app/motor/protocolo usada.
- Resolver cómo obtener/compilar el binario `windows/engine/engine.exe` y separar build de demo del empaquetado real si se desea independencia.
- Crear issues por entrega con propietario, evidencia y criterio de aceptación; no seguir trabajando sobre un alcance ambiguo.

**Cierre:** una instalación de desarrollo reproducible y decisiones escritas sobre plataformas, propiedad del motor y política de cierre.

### P1 — Integración de solo lectura

**Responsables:** motor + adaptador Flutter; apoyo de backend y QA.

- Revisar el contrato de `AudioUiPort` con eventos reales anonimizados.
- Añadir identificación de sesión y matriz de capacidades/protocolo si lo exige el motor.
- Construir el adaptador real bajo alcance nuevo; validar esquemas, IDs, fechas y unidades.
- Mostrar conexión, motor, zonas, pista, dispositivos y métricas reales solo si existen; usar desconocido para datos ausentes.
- Diseñar desconexión/frescura, reconexión con espera progresiva y descarte de eventos viejos.

**Cierre:** UI de solo lectura comparada contra el motor local, sin datos simulados mezclados y con errores/desconexión visibles.

### P2 — Control de zonas y reproducción

**Responsables:** motor, Flutter, backend para autorización y QA.

- Volumen, habilitación y canales: capacidad negociada, comandos con ID, validación y resultado aplicado.
- Play/pause, selección de pista, cola, anterior/siguiente, seek y modos: acordar primero semántica y autoridad.
- Agrupar volumen durante arrastre; tratar operaciones pendientes y rechazos sin bloquear toda la UI.
- Definir comportamiento ante eliminación de zona, salida desconectada, múltiples operadores y revisiones en conflicto.
- Probar parada y cierre ordenados, sin doble proceso o audio huérfano.

**Cierre:** cada acción se verifica con estado del motor y audio físico; probar timeout, repetición de solicitudes, errores y recuperación.

### P3 — Biblioteca, dispositivos y configuración real

**Responsables:** producto/backend/motor/Flutter según dato.

- Biblioteca: fuentes disponibles, playlists, metadatos, carátulas, búsqueda real, carga y paginación.
- Dispositivos: identificadores estables, permisos, capacidades por plataforma, drivers y cambio de salida real.
- Configuración: distinguir configuración deseada/aplicada; permisos y auditoría; no asumir que cualquier usuario local puede administrar el equipo.
- Mapas: planos por instalación, posiciones persistidas, alta/baja/renombrado de zonas y fallback si el recurso falla.

**Cierre:** catálogo y configuración sobreviven reinicios según política acordada; fallos de recursos y dispositivos no rompen la pantalla.

### P4 — Fiabilidad, datos y seguridad operativa

**Responsables:** motor y backend; Flutter muestra estados y errores; QA valida.

- Acordar reproducción offline, caché, caducidad y reconciliación al volver la red.
- Asignar propiedad de tokens y almacenamiento por plataforma; rotación/revocación y redacción de logs.
- Identificar schemas de datos, backup y migraciones. Preferencias UI no deben sobrescribir configuración del motor.
- Definir límites de eventos/logs, watchdog y recuperación frente a proceso caído sin bucles de reinicio.
- Medir memoria, frames y CPU en ejecución prolongada; revisar liberación de timers/streams y eventos frecuentes.
- Validar teclado, lector de pantalla, alto contraste, DPI, texto ampliado y movimiento reducido.

**Cierre:** matriz de fallos ejecutada con resultados y sin pérdida de configuración o secretos expuestos.

### P5 — Distribución, actualizaciones y soporte

**Responsables:** release/operaciones técnicas, dueños de app/motor y QA.

- Windows: instalador y firma; paquete completo con motor y runtimes; instalación/actualización/desinstalación.
- macOS: motor compatible, sandbox/entitlements, bundle propio, firma/notarización y equipos de prueba.
- Web: hosting, rutas, caché y política de actualización de assets; si controla dispositivos, API/autorización y acceso remoto aprobados.
- CI por SO: SDK fijado, análisis, tests, builds, versiones, artefactos y firmas mediante secretos administrados.
- Entrega manual primero; actualizar automáticamente después de validar rollback y la matriz app/motor/datos.
- Preparar release notes, guía de instalación, diagnóstico exportable y responsable de incidentes.

**Cierre:** un piloto puede instalar, actualizar y volver a una versión compatible con instrucciones verificadas.

## 3. Decisiones que debe tomar el propietario del producto

| Decisión | Por qué bloquea trabajo |
| --- | --- |
| ¿Web es demo o control remoto? | Cambia arquitectura, permisos y alcance de seguridad |
| ¿Windows es el primer destino productivo? | Define drivers, hardware y pipeline inicial |
| ¿Audio continúa al cerrar la UI? | Define proceso hijo vs servicio y actualizaciones |
| ¿Qué puede funcionar sin internet? | Determina caché, autenticación y sincronización |
| ¿Una o varias salidas por zona/equipo? | Cambia contratos y routing |
| ¿Quién administra equipo, volumen y biblioteca? | Determina autorización y auditoría |
| ¿Quién distribuye y firma las versiones? | Define instalador, credenciales de firma y soporte |
| ¿Qué versiones previas se soportan? | Define migraciones, compatibilidad y rollback |
| ¿Qué datos deben conservarse al reinstalar? | Evita pérdida de configuración/secretos |

Estas respuestas todavía no están acordadas por el código de preview.

## 4. Responsabilidades continuas

- **Antes de cada cambio:** identificar capa afectada, leer registro, conservar cambios existentes y definir aceptación.
- **Por entrega:** análisis y pruebas pertinentes; comparar capturas si cambia UI; registrar versiones y limitaciones.
- **Antes de actualizar dependencias:** revisar incompatibilidades, una familia de cambios por vez y ruta de retorno.
- **Antes de distribuir:** verificar banderas, origen de datos, paquete completo, firma, compatibilidad y actualización desde la versión soportada anterior.
- **Tras distribuir:** observar errores/diagnóstico, registrar incidentes y ofrecer retorno seguro; no tocar credenciales o audio en caliente sin política definida.

La cadencia debe acordarse según el uso operativo. No hay tareas automáticas programadas por esta guía.

## 5. Plantilla para una próxima tarea

```text
Problema y usuario afectado:
Capa y archivos previstos:
Responsable de decisión / implementación / QA:
Estado actual observado:
Resultado verificable esperado:
Capacidades o contratos necesarios:
Errores y límites que deben cubrirse:
Plataformas y versiones:
Pruebas y evidencia:
Migración y rollback si aplica:
Documentación a actualizar:
Aprobación de alcance:
```

Un siguiente alcance razonable es **P0 + acuerdo del contrato**, seguido de un adaptador solo lectura. No hace falta rediseñar otra vez la UI para empezar a validar datos reales, pero no debe cambiarse su origen sin esa integración explícita.
