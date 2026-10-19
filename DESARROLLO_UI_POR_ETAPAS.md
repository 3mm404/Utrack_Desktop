# UTRACK ENGINE — Desarrollo progresivo de interfaz Flutter

## 1. Contexto del proyecto

Estamos desarrollando **UTRACK Engine**, una aplicación de escritorio construida con Flutter para controlar un motor de audio, administrar zonas de reproducción, gestionar dispositivos y controlar contenido musical.

El diseño debe inspirarse en la imagen de referencia proporcionada, buscando una interfaz de escritorio premium, minimalista, oscura, realista y técnicamente sofisticada.

No queremos una interfaz genérica de Material Design. Buscamos una identidad visual propia, cercana al software profesional de audio, con acabados refinados y una experiencia de usuario consistente.

## 2. Tu rol

Actúa como un Senior Flutter Desktop Engineer, Software Architect y UI/UX Engineer especializado en interfaces profesionales.

Tus responsabilidades serán:

- Analizar la estructura existente antes de modificar archivos.
- Diseñar componentes reutilizables y desacoplados.
- Mantener una arquitectura modular y escalable.
- Respetar las convenciones existentes del proyecto.
- Evitar dependencias innecesarias.
- Priorizar rendimiento y mantenibilidad.
- Implementar interfaces visualmente precisas.
- Trabajar estrictamente por etapas.

**REGLA PRINCIPAL: NO IMPLEMENTES TODO EL PROYECTO EN UNA SOLA EJECUCIÓN.**

Al terminar cada etapa, detente y espera mi aprobación explícita antes de continuar.

## 3. Dirección visual

La interfaz debe tener las siguientes características:

**Estilo general**

- Dark UI premium.
- Minimalismo tecnológico.
- Superficies en tonos negro carbón y grafito.
- Bordes discretos y separadores sutiles.
- Acentos metálicos cálidos, próximos al champagne.
- Indicadores verdes exclusivamente para estados operativos.
- Esquinas redondeadas y geometría consistente.
- Sombras suaves y profundidad visual moderada.
- Tipografía moderna, legible y profesional.
- Animaciones fluidas, discretas y funcionales.

Evitar:

- Colores neón excesivos.
- Estética cyberpunk.
- Glassmorphism exagerado.
- Gradientes decorativos innecesarios.
- Componentes genéricos sin personalización.
- Efectos visuales que perjudiquen el rendimiento.

## 4. Composición principal

La aplicación tendrá cinco regiones visuales:

### A. Sidebar

Barra de navegación lateral con:

- Identidad UTRACK Engine.
- Inicio.
- Zonas.
- Biblioteca.
- Dispositivos.
- Ajustes.
- Estado del motor en la parte inferior.

### B. Header

Barra superior con:

- Buscador.
- Indicador de conexión.
- Acceso a configuración.

### C. Visualizador de zonas

Panel principal con:

- Plano isométrico de una vivienda.
- Indicadores de zonas de audio.
- Controles individuales de volumen.
- Identificación de zonas activas.
- Selección de habitaciones.

Inicialmente, el plano será una imagen estática con controles Flutter superpuestos.

No implementar un motor 3D todavía.

### D. Paneles de control

Sección lateral con:

- Zona seleccionada.
- Control circular de volumen.
- Fuente de reproducción.
- Configuración de canales.
- Canción actual.
- Dispositivo de salida.
- Estado del motor.
- Métricas de rendimiento.

### E. Reproductor inferior

Barra de reproducción con:

- Carátula del contenido.
- Nombre de canción y artista.
- Barra de progreso.
- Reproducir / pausar.
- Anterior / siguiente.
- Reproducción aleatoria.
- Repetición.
- Volumen.

## 5. Reglas de implementación

1. Utiliza Flutter y Dart.
2. Prioriza widgets personalizados y reutilizables.
3. Centraliza colores, tipografía, espaciados, radios y sombras mediante design tokens.
4. Evita valores visuales arbitrarios repetidos.
5. Separa presentación, estado y lógica de negocio.
6. Utiliza recursos SVG o WebP cuando corresponda.
7. No conviertas paneles completos en imágenes.
8. Usa `CustomPainter` solamente cuando aporte valor.
9. Evita introducir paquetes sin justificar su necesidad.
10. No implementes todavía integraciones reales con el motor de audio.
11. Utiliza datos simulados claramente identificados.
12. Mantén compatibilidad con Flutter Desktop, priorizando Windows.
13. Diseña pensando en resoluciones de escritorio y ventanas redimensionables.
14. No modifiques funcionalidades existentes sin necesidad.
15. No reemplaces la arquitectura existente sin analizarla primero.

## 6. Plan de desarrollo por etapas

### ETAPA 0 — Auditoría y planificación

Antes de escribir código:

- Inspecciona el proyecto Flutter.
- Identifica su arquitectura y dependencias.
- Revisa los componentes existentes.
- Detecta posibles conflictos.
- Propón una estructura de carpetas.
- Define un plan de implementación.
- Identifica los recursos gráficos que necesitaremos.

**Entregable:** diagnóstico técnico y propuesta de arquitectura.

No modifiques archivos en esta etapa.

### ETAPA 1 — Sistema de diseño

Implementar exclusivamente:

- Paleta de colores.
- Tipografía.
- Espaciados.
- Radios.
- Bordes.
- Sombras.
- Estilos de tarjetas.
- Estilos de botones.
- Tokens visuales reutilizables.

No construir todavía el dashboard completo.

### ETAPA 2 — Estructura principal

Implementar exclusivamente:

- Layout general.
- Sidebar.
- Header.
- Contenedores principales.
- Distribución responsive para escritorio.
- Navegación visual básica.

Utilizar placeholders para las secciones aún no desarrolladas.

### ETAPA 3 — Componentes visuales reutilizables

Implementar:

- Tarjetas.
- Botones circulares.
- Indicadores de estado.
- Sliders.
- Controles de iconos.
- Filas de configuración.
- Encabezados de panel.

Cada componente debe tener una responsabilidad concreta.

### ETAPA 4 — Visualizador de zonas

Implementar:

- Contenedor del plano.
- Imagen isométrica.
- Marcadores de habitaciones.
- Indicadores de volumen.
- Selección visual de zonas.
- Estados activos e inactivos.

Utilizar datos simulados.

### ETAPA 5 — Panel de zona seleccionada

Implementar:

- Información de zona.
- Perilla de volumen interactiva.
- Fuente.
- Canales.
- Canción actual.
- Estados y animaciones.

### ETAPA 6 — Dispositivos y estado del motor

Implementar:

- Panel de salida de audio.
- Imagen del dispositivo.
- Información del driver.
- Métricas de CPU.
- Latencia.
- Estado del motor.

Los datos serán simulados hasta integrar el backend.

### ETAPA 7 — Reproductor musical

Implementar:

- Carátula.
- Metadatos.
- Controles de reproducción.
- Barra de progreso.
- Volumen.
- Estados visuales.

No integrar reproducción real todavía.

### ETAPA 8 — Estado y comportamiento

Conectar los componentes mediante un sistema de estado apropiado.

Implementar interacciones coherentes entre:

- Zona seleccionada.
- Volumen.
- Reproducción.
- Dispositivos.
- Indicadores.

### ETAPA 9 — Refinamiento visual

Revisar:

- Consistencia de espaciados.
- Alineación.
- Jerarquía visual.
- Contraste.
- Sombras.
- Animaciones.
- Rendimiento.
- Adaptación a diferentes tamaños de ventana.

Comparar el resultado con la referencia y corregir diferencias.

### ETAPA 10 — Preparación para integración

Definir contratos e interfaces para conectar posteriormente el motor real de audio.

No implementar un backend ficticio como si fuera una integración funcional.

## 7. Protocolo obligatorio de trabajo

Para cada etapa:

1. Explica qué vas a implementar.
2. Identifica los archivos que crearás o modificarás.
3. Indica las decisiones técnicas relevantes.
4. Implementa únicamente el alcance aprobado.
5. Ejecuta análisis estático y pruebas pertinentes cuando sea posible.
6. Informa qué se implementó y qué quedó pendiente.
7. Detente.

No avances automáticamente a la siguiente etapa.

No anticipes componentes de etapas futuras salvo que sean estrictamente necesarios.

Si encuentras un problema arquitectónico, explícalo antes de realizar cambios importantes.

## 8. Primera instrucción

**Comienza únicamente con la ETAPA 0: auditoría y planificación.**

Inspecciona el proyecto actual y presenta tu diagnóstico, la estructura propuesta y el plan de implementación.

No escribas código todavía.

Espera mi autorización para comenzar la ETAPA 1.

## 9. Acuerdo de alcance y seguimiento

- Repositorio: `C:\Develop\ENGINE\Utrack_Desktop`.
- Trabajaremos exclusivamente en la capa de presentación (View) de Flutter.
- No modificaremos lógica de negocio, servicios, backend ni el motor de audio. Si una etapa necesita cambios fuera de la View, se explicará antes y requerirá autorización explícita.
- Los datos simulados estarán claramente identificados y se limitarán a las necesidades de presentación.
- Documentaremos por etapa: alcance aprobado, archivos creados o modificados, decisiones técnicas, validaciones realizadas y pendientes.
- Al finalizar cada etapa, nos detendremos y esperaremos aprobación explícita antes de comenzar la siguiente.
- La Etapa 0 consiste únicamente en auditoría y planificación, sin modificar archivos del proyecto.
- Este documento registra el plan; su creación no inicia ni aprueba ninguna etapa de implementación.
- Estado actual: Etapas 0–10 finalizadas dentro del alcance de UI, preparación de contratos y documentación. Integración real y distribución productiva pendientes de nuevos alcances.

### Plantilla de registro por etapa

- **Etapa:**
- **Alcance aprobado:**
- **Archivos involucrados:**
- **Decisiones técnicas:**
- **Trabajo realizado:**
- **Validaciones y resultados:**
- **Pendientes:**
- **Estado y aprobación para continuar:**

## 10. Registro de avance

### Etapa 0 — Auditoría y planificación

- Completada mediante inspección, sin modificar archivos en esa etapa.
- Arquitectura existente: views, controllers, models y services. Se conserva.
- Componentes reutilizables identificados: SectionCard y ZoneConsole.
- Hallazgos: valores visuales repetidos y tema definido en main.dart.
- Etapa 1 autorizada explícitamente por el usuario.

### Etapa 1 — Sistema de diseño

- **Alcance aprobado:** exclusivamente UI; sin cambios a controladores, servicios, modelos o comportamiento.
- **Archivos creados:** lib/views/design/ui_tokens.dart y lib/views/design/ui_theme.dart.
- **Archivos modificados:** lib/main.dart (solo conexión del tema), lib/views/widgets/section_card.dart y este registro.
- **Decisiones:** paleta carbón/grafito con acento champagne; verde semántico reservado a estados operativos; tipografía de plataforma sin dependencias; escala de espaciados, radios, bordes y sombra discreta reutilizables.
- **Trabajo realizado:** tema oscuro centralizado, jerarquía tipográfica, estilos de tarjetas, botones, campos y tooltips. SectionCard utiliza tokens. No se construyen secciones ni componentes de etapas futuras.
- **Validaciones:** dart analyze sin problemas. Pruebas de interfaz ejecutadas: 3 aprobadas y 1 fallida. La prueba dashboard_test.dart espera un único texto Terraza, pero la vista actual lo presenta en la lista y el selector de ZoneConsole; se registra el desajuste sin modificar la prueba ni esas vistas. Formato Dart aplicado.
- **Pendientes:** revisar visualmente con la referencia cuando esté disponible; migrar los estilos locales restantes al desarrollar cada sección; resolver el desajuste de la prueba del dashboard en el alcance correspondiente.
- **Estado:** implementación de Etapa 1 terminada, con la incidencia de prueba indicada. Detenida a la espera de revisión y autorización explícita para Etapa 2.

### Etapa 2 — Estructura principal

- **Alcance aprobado:** solo UI; layout general, sidebar, header, contenedores adaptables y navegación visual con placeholders.
- **Archivos creados:** lib/views/layout/utrack_sidebar.dart, utrack_header.dart y utrack_shell.dart.
- **Archivos modificados:** lib/views/engine_dashboard.dart (conexión de la nueva estructura al modo test) y este documento.
- **Decisiones:** estructura nueva solo en modo test para revisar progresivamente; sin modificar controladores, servicios ni modelos. Sidebar extendida desde 1000 px, compacta entre 600 y 999 px, navegación inferior por debajo de 600 px. Paneles laterales apilados cuando no hay espacio.
- **Trabajo realizado:** identidad UTRACK Engine; navegación Inicio, Zonas, Biblioteca, Dispositivos y Ajustes; estado del motor inferior; header con búsqueda local de secciones al pulsar Enter, indicador de conexión y acceso a ajustes. Inicio muestra espacios reservados para plano, zona seleccionada, dispositivo y reproductor. Ajustes conserva acceso a configuración y actividad existentes. Sin funciones de audio nuevas.
- **Validaciones:** dart analyze sin problemas; test/widget_test.dart: 2 pruebas aprobadas, incluida navegación a ajustes a 390 px. Formato Dart aplicado.
- **Pendientes:** desarrollo visual de las secciones en sus etapas correspondientes; referencia gráfica; incidencia de prueba del dashboard registrada en Etapa 1.
- **Estado:** Etapa 2 terminada. Detenida hasta aprobación explícita de Etapa 3.

### Etapa 3 — Componentes visuales reutilizables

- **Alcance aprobado:** solo UI; tarjetas, botones circulares, indicadores de estado, sliders, controles de iconos, filas de configuración y encabezados de panel.
- **Archivos creados:** lib/views/widgets/panel_header.dart, status_indicator.dart, ui_controls.dart, configuration_row.dart; test/ui_components_test.dart.
- **Archivos modificados:** lib/views/widgets/section_card.dart, lib/views/layout/utrack_header.dart y este registro.
- **Decisiones:** conservar SectionCard y extraer PanelHeader; controles de presentación con valores y callbacks suministrados por el consumidor; sin dependencias nuevas ni acceso a controladores o servicios. Se aprovechan foco, teclado y estados deshabilitados nativos de Flutter. Tooltips, etiquetas semánticas y color operativo verde.
- **Trabajo realizado:** PanelHeader integrado en SectionCard; StatusIndicator y UiIconControl integrados en el header; CircularControl reutiliza UiIconControl; UiSlider muestra etiqueta y valor, acota el valor recibido y emite callbacks sin persistencia; ConfigurationRow apila texto y control en espacios estrechos. Los controles restantes quedan disponibles para sus etapas, sin construir paneles futuros.
- **Validaciones:** dart analyze sin problemas. Cuatro pruebas aprobadas entre ui_components_test.dart y widget_test.dart: callbacks y deshabilitado, slider y fila estrecha, modo simulado y navegación a 390 px. Formato Dart y revisión de espacios aplicados.
- **Pendientes:** aplicar controles al desarrollar los paneles posteriores; referencia visual y desajuste de prueba del dashboard ya registrados en etapas anteriores.
- **Estado:** Etapa 3 terminada. Detenida hasta aprobación explícita de Etapa 4.

### Etapa 4 — Visualizador de zonas

- **Alcance aprobado:** exclusivamente UI. Plano estático, marcadores, selección de habitaciones, volumen y estados simulados.
- **Referencia:** imagen adjunta del usuario con plano de vivienda e interfaz oscura champagne. Se toma como dirección visual; no se incrusta la captura del panel como interfaz.
- **Archivos creados:** lib/views/widgets/zone_map.dart, assets/images/zone_floor_plan.png y test/zone_map_test.dart.
- **Archivos modificados:** lib/views/layout/utrack_shell.dart, pubspec.yaml (registro del recurso) y este documento.
- **Trabajo realizado:** ZoneMap disponible en Inicio y Zonas del modo test; plano arquitectónico sin controles incrustados; cuatro marcadores Flutter con selección, tooltip de nombre/volumen/estado, borde champagne y verde solo para estado activo. Controles independientes de volumen y activación; tarjetas en dos columnas o una según el espacio.
- **Decisiones:** coordenadas normalizadas sobre una imagen cuadrada para conservar alineación al redimensionar. Estado efímero local a ZoneMap: sin controlador, servicios, persistencia o conexión al motor. La selección y los cambios no se sincronizan todavía con los paneles laterales; quedan para las etapas 5 y 8. No se construye motor 3D.
- **Recurso gráfico:** generado con la herramienta integrada imagegen y copiado al proyecto. Imagen inspeccionada para verificar las cuatro habitaciones y la ausencia de controles o textos incrustados.
- **Validaciones:** seis pruebas aprobadas entre zone_map_test.dart, ui_components_test.dart y widget_test.dart. Incluyen selección, ajuste de volumen, activación, carga del recurso y ausencia de excepciones a 390 y 1280 px. Formato Dart aplicado; análisis estático sin problemas.
- **Pendientes:** panel de zona seleccionada (Etapa 5), dispositivo/motor (Etapa 6), reproductor (Etapa 7), coordinación del estado (Etapa 8) y refinamiento contra referencia (Etapa 9). Incidencia del test legacy del dashboard conservada como pendiente anterior.
- **Estado:** Etapa 4 terminada. Detenida hasta aprobación explícita de Etapa 5.

#### Prompt del recurso gráfico (imagegen integrado)

Create a project asset: a high-quality static isometric architectural dollhouse floor plan for a premium dark professional audio application. Square image 1024x1024. One roofless contemporary apartment with four identifiable spaces: terrace with plants at top left, kitchen with warm wood cabinetry at top right, living room with beige sectional sofa and round coffee table bottom left, dining room with long dark table and chairs bottom right. Orthographic isometric view from elevated front, entire house footprint visible with generous empty dark charcoal margin around edges. Dark graphite background #14171b, realistic stone floors, warm champagne lighting, understated sophisticated architectural visualization, clear room boundaries. No text, no UI, no labels, no markers, no circular dials, no border. Only the architectural illustration; never draw an app screenshot.

### Etapa 5 — Panel de zona seleccionada

- **Alcance aprobado:** solo UI; información de zona, perilla interactiva, fuente, canales, canción, estados y animaciones.
- **Archivos creados:** lib/views/widgets/selected_zone_panel.dart, lib/views/widgets/volume_knob.dart, lib/views/state/zone_preview_state.dart y test/selected_zone_panel_test.dart.
- **Archivos modificados:** lib/views/widgets/zone_map.dart, lib/views/layout/utrack_shell.dart y este registro.
- **Decisiones:** extraer el estado simulado del plano a ZonePreviewState dentro de views/state, exclusivamente para compartir selección, volumen y estado con el panel. Sin modificar controladores, modelos de negocio, servicios ni motor. Estado retenido durante la sesión del shell, sin persistencia. La coordinación restante de dispositivos y reproducción corresponde a Etapa 8.
- **Trabajo realizado:** panel sustituye el placeholder en Inicio y Zonas; navegación anterior/siguiente, nombre y estado de zona, fuente/playlist y canción simuladas; selector Mono/Estéreo. Perilla champagne con arco animado, arrastre vertical, flechas de teclado, semántica accesible y botones de ajuste de un punto. Cambio de nombre animado y activación simulada. Volumen limitado a 0–100. Plano y panel reflejan inmediatamente los cambios mutuos.
- **CustomPainter:** se utiliza únicamente para el arco parcial del volumen; superficie, puntero, texto y controles siguen siendo widgets Flutter.
- **Validaciones:** dart analyze sin problemas. Ocho pruebas aprobadas entre selected_zone_panel_test.dart, zone_map_test.dart, ui_components_test.dart y widget_test.dart. Incluyen arrastre, teclado, límites, selección y volumen compartidos, y ventana de 390 px. Formato Dart y revisión de espacios aplicados.
- **Pendientes:** dispositivos/estado del motor (Etapa 6), reproductor (Etapa 7), coordinación adicional (Etapa 8) y refinamiento visual (Etapa 9). Fuente y canción son ejemplos de presentación, sin reproducción ni conexión real.
- **Estado:** Etapa 5 terminada. Detenida hasta aprobación explícita de Etapa 6.

### Etapa 6 — Dispositivos y estado del motor

- **Alcance aprobado:** solo UI; panel de salida, imagen de dispositivo, driver, CPU, latencia y estado del motor mediante datos simulados.
- **Archivos creados:** lib/views/widgets/audio_output_panel.dart, lib/views/widgets/engine_status_panel.dart y assets/images/audio_interface.png.
- **Archivos modificados:** lib/views/layout/utrack_shell.dart, pubspec.yaml (registro del recurso) y este documento.
- **Trabajo realizado:** AudioOutputPanel presenta interfaz USB ficticia, driver ASIO de ejemplo Windows, estéreo, frecuencia, buffer y canales. EngineStatusPanel presenta zonas activas, estado, CPU y latencia con barras accesibles. Paneles disponibles en Inicio/Zonas y en Dispositivos; disposición horizontal en Dispositivos con espacio suficiente y vertical en ventanas estrechas.
- **Decisiones:** datos estáticos claramente rotulados como simulados, sin detección de hardware ni consulta del sistema. No se añaden temporizadores o métricas aleatorias. Conteo inicial de zonas 2/4 como ejemplo; coordinación dinámica con zonas y dispositivos reservada para Etapa 8. ASIO es una muestra visual de Windows, no una afirmación de compatibilidad o disponibilidad del driver en macOS/web. No se modifican controladores, servicios o motor.
- **Recurso gráfico:** imagen generada con imagegen integrado, inspeccionada visualmente y copiada al proyecto. Dispositivo sin marca; panel y métricas siguen siendo widgets Flutter.
- **Validaciones:** dart analyze sin problemas. En la ejecución de ocho pruebas UI, siete pasaron y una detectó formato incorrecto en la etiqueta accesible de latencia. Corregido usando valor porcentual numérico para la barra y latencia en su etiqueta; repetición de test/widget_test.dart: dos pruebas aprobadas, incluida navegación a 390 px. Formato Dart y revisión de espacios aplicados.
- **Pendientes:** reproductor (Etapa 7), coordinación de estado (Etapa 8), refinamiento visual (Etapa 9) y conexión futura mediante contratos (Etapa 10). Los valores mostrados no representan mediciones reales.
- **Estado:** Etapa 6 terminada. Detenida hasta aprobación explícita de Etapa 7.

#### Prompt del recurso gráfico de dispositivo (imagegen integrado)

Product illustration asset for premium dark audio software. A realistic compact professional desktop USB audio interface, unbranded black brushed metal chassis, two front XLR combo inputs, a small volume knob, discreet warm champagne highlights. Three-quarter perspective from above front left, front and top visible. Centered entire device with generous margins. Wide landscape composition. Plain solid very dark graphite background #101317, soft studio lighting, subtle contact shadow. No text, no logos, no labels, no cables, no UI, no people. Only the physical audio interface.

### Etapa 7 — Reproductor musical

- **Alcance aprobado:** exclusivamente UI; carátula, metadatos, transporte, progreso, volumen y estados visuales. Sin reproducción real.
- **Archivos creados:** lib/views/widgets/player_bar.dart y test/player_bar_test.dart.
- **Archivos modificados:** lib/views/layout/utrack_shell.dart y este registro.
- **Trabajo realizado:** barra persistente en la parte inferior del contenido del modo test, disponible en todas las secciones. Carátula de vinilo construida con widgets Flutter; título, artista y duración de tres pistas ficticias. Reproducir/pausar, anterior/siguiente, estado de aleatorio y repetición, posición manual, volumen y silencio con restauración del nivel anterior. Layout horizontal amplio y apilado en ventanas estrechas.
- **Decisiones:** reutilizar UiIconControl y CircularControl, colores y medidas centralizados. Carátula vectorial nativa sin recurso externo ni paquetes. Estado efímero local a PlayerBar, retenido al navegar entre secciones. No se modifican controladores, servicios ni motor.
- **Límites de simulación:** reproducir/pausar modifica el estado visual; el progreso es manual y no tiene reloj o avance automático. Aleatorio utiliza un orden alternativo determinista para la navegación de prueba; repetir solo mantiene el estado visual hasta implementar la coordinación de Etapa 8. Etiqueta visible de vista previa sin audio real. El reproductor aún no se sincroniza con la zona seleccionada.
- **Validaciones:** dart analyze sin problemas. Diez pruebas UI aprobadas entre player_bar_test.dart, widget_test.dart, selected_zone_panel_test.dart, zone_map_test.dart y ui_components_test.dart. Incluyen transporte, posición reiniciada al cambiar pista, silencio/restauración, estados de aleatorio/repetición y ausencia de errores a 390 y 1280 px. Formato Dart y revisión de espacios aplicados.
- **Pendientes:** coordinación entre zonas, reproducción, dispositivos e indicadores (Etapa 8), refinamiento visual (Etapa 9) y preparación de contratos (Etapa 10). Permanece registrada la incidencia anterior del test legacy del dashboard.
- **Estado:** Etapa 7 terminada. Detenida hasta aprobación explícita de Etapa 8.

### Etapa 8 — Estado y comportamiento

- **Alcance aprobado:** coordinación de componentes mediante estado de presentación; zonas, volumen, reproducción simulada, dispositivos e indicadores. Solo UI; no se modifican servicios, controladores, modelos de negocio o motor.
- **Estado compartido:** ZonePreviewState (ChangeNotifier existente bajo views/state) pasa a ser la fuente de estado para el plano, panel seleccionado, reproductor y dispositivo. Cada zona conserva pista, posición, volumen, silencio/restauración, modo de canales, reproducción, repetición y orden alternativo. El estado sigue siendo efímero y dura la sesión del shell.
- **Archivos modificados:** lib/views/state/zone_preview_state.dart; widgets/player_bar.dart, audio_output_panel.dart, engine_status_panel.dart, selected_zone_panel.dart, zone_map.dart; layout/utrack_shell.dart, utrack_sidebar.dart; test/player_bar_test.dart; este documento.
- **Archivos creados:** test/zone_preview_state_test.dart y test/preview_coordinator_test.dart.
- **Trabajo realizado:** reproductor sigue la zona seleccionada y comparte volumen/pista con el panel. Reloj simulado de un segundo avanza todas las zonas que reproducen, incluso si no están seleccionadas. Pausar conserva posición. Fin de pista pasa a la siguiente; repetir vuelve a la misma pista; aleatorio conserva un orden alternativo determinista para revisión. El temporizador se cancela sin reproducción y al liberar el estado.
- **Dispositivos y motor:** selector entre interfaz USB y salida virtual de ejemplo; cambiar salida pausa las zonas y actualiza driver/latencia. Arranque/parada simulados coordinan sidebar, header, paneles y controles. Detener pausa todo, bloquea play y muestra CPU, latencia y zonas activas en cero. Reiniciar no reanuda automáticamente.
- **Indicadores:** zonas activas significa zonas habilitadas con motor simulado iniciado; el panel distingue habilitada de reproduciendo. CPU es una fórmula de demostración según zonas reproduciendo; latencia depende del dispositivo ficticio. No son mediciones del sistema. Volumen, canales y pista pueden prepararse en pausa.
- **Corrección UI necesaria:** etiquetas de sidebar dentro de Expanded para evitar desbordamiento detectado en la prueba del shell con tipografía de prueba a 1280 px.
- **Validaciones:** dart analyze sin problemas. Dieciséis pruebas aprobadas de estado y regresión UI, más dos de temporizador/coordinación del shell aprobadas tras ajustar la sidebar (18 en total). Cubren conservación por zona, reloj, pausa, límites de pista, repetición/orden alternativo, salida, parada del motor, controles bloqueados y liberación de temporizadores. Formato Dart aplicado.
- **Pendientes:** refinamiento visual contra referencia (Etapa 9), contratos para integración futura (Etapa 10) e incidencia legacy del dashboard documentada en Etapa 1. No hay reproducción ni detección de dispositivos real.
- **Estado:** Etapa 8 terminada. Detenida hasta aprobación explícita de Etapa 9.

### Etapa 9 — Refinamiento visual

- **Alcance aprobado:** exclusivamente presentación: distribución, espaciados, alineación, jerarquía, contraste, animaciones, adaptación de ventanas y revisión contra la referencia.
- **Diagnóstico visual:** el plano sin límite de tamaño y los paneles apilados ocultaban información fuera del área visible. Se revisaron capturas antes y después; las imágenes se precargan en el harness para evitar capturas antes de finalizar su decodificación.
- **Archivos modificados:** lib/views/layout/utrack_shell.dart y utrack_header.dart; widgets/section_card.dart, zone_map.dart, selected_zone_panel.dart, volume_knob.dart, audio_output_panel.dart y engine_status_panel.dart; test/dashboard_test.dart y este registro.
- **Archivo creado:** test/ui_visual_review_test.dart, harness de capturas y verificación de tamaños/accesibilidad.
- **Trabajo realizado:** tres columnas en escritorio amplio (plano, zona, salida/estado); dos columnas en tamaño intermedio y distribución vertical estrecha. Plano limitado y centrado, selección mediante chips de nombre/volumen; controles detallados conservados en la variante independiente del plano y panel seleccionado. Paneles compactos mantienen acceso a fuente, canales, canción, cambio de salida y motor. Header prioriza búsqueda y alinea conexión/ajustes a la derecha. Reproductor continúa fijo abajo.
- **Consistencia:** padding y separaciones con tokens, encabezados coherentes, controles de 48 px y estados operativos verdes. La perilla tiene foco visible de teclado; perilla y cambio de nombre respetan movimiento reducido. Las variantes completas de dispositivo/motor siguen disponibles en Dispositivos.
- **Renderizado:** escena estática limitada y aislada con RepaintBoundary para acotar pintura; sin motor 3D, paquetes o efectos decorativos nuevos. No se hicieron mediciones de FPS ni pruebas en hardware macOS.
- **Indicadores:** header y sidebar muestran el mismo estado simulado del shell; se conserva el alcance exclusivamente visual.
- **Validaciones:** dart analyze sin problemas; suite completa: 31 pruebas aprobadas y 1 integración de proceso omitida por su condición existente. Se resolvió la incidencia legacy de Etapa 1 usando aserciones de presencia para textos de zona/estado que legítimamente aparecen en más de un widget. Cinco tamaños renderizados sin errores: 1672x941, 1280x850, 720x800, 390x844 y 1280x650; comprobación adicional de texto al 150% y movimiento reducido. Capturas de escritorio amplio, intermedio y estrecho inspeccionadas visualmente. Formato Dart y revisión de espacios aplicados.
- **Capturas:** build/previews/stage9-1672x941.png, stage9-1280x850.png, stage9-720x800.png, stage9-390x844.png y stage9-1280x650.png. Son artefactos regenerables del harness dentro de build.
- **Comparación:** se aproxima la composición de tres columnas, paleta champagne, paneles oscuros y reproductor inferior de la referencia. Se mantiene una ilustración propia y controles Flutter, sin intentar una copia píxel a píxel de la captura.
- **Pendientes:** preparación de contratos para integración futura (Etapa 10). Continúa siendo una UI de prueba sin reproducción o hardware real.
- **Estado:** Etapa 9 terminada. Detenida hasta aprobación explícita de Etapa 10.

### Etapa 10 — Preparación para integración y documentación de continuidad

- **Alcance aprobado:** definir contratos/interfaces para futura integración, sin conectar el motor ni implementar un backend ficticio; documentar estructura, responsabilidades, actualizaciones, requisitos y trabajo posterior.
- **Archivo de contrato creado:** lib/views/contracts/audio_ui_port.dart. Declara AudioUiPort, snapshots inmutables con colecciones no modificables, enums de estado/capacidades, comandos explícitos por ID/revisión y resultados tipados. No contiene transporte, serialización, adaptador, credenciales ni conexión a widgets.
- **Documentos creados:** docs/ARQUITECTURA.md, docs/INTEGRACION.md, docs/MANTENIMIENTO.md y docs/ROADMAP.md.
- **Documentos modificados:** README.md (índice y arranque; reemplaza el bloque Python pegado anteriormente) y esta bitácora.
- **Decisiones:** contrato dentro de views/contracts como frontera de presentación; EngineBridge y EngineController se conservan sin cambios. La UI continúa simulada. Comandos expresan valores deseados, no toggles ambiguos. Aceptación no equivale a aplicación confirmada. Las métricas desconocidas son null. Se explicitan capacidades y validación futura.
- **Arquitectura documentada:** separación entre el preview de UI y el bridge anterior, composición y propiedad de estado/recursos, responsabilidad de Flutter, motor, backend, producto, QA y distribución. Se detalla que biblioteca es placeholder y buscador solo navega secciones.
- **Actualizaciones documentadas:** separar SDK/dependencias, app, motor y datos; matriz de versiones, paquetes completos, firma, migraciones, recuperación y futuro actualizador. No se instala ni ejecuta un actualizador.
- **Bloqueos verificados:** falta windows/engine/engine.exe en el árbol inspeccionado; el CMake Windows exige ese binario. build-windows.ps1 compila el motor hermano y luego la vista de producción anterior sin bandera test. macOS conserva identidad de ejemplo y sandbox Release sin acceso de red saliente declarado; se requiere auditoría nativa. Web sigue siendo preview sin proceso local. Ninguno se modifica fuera del alcance UI/documentación.
- **Plan posterior:** P0 decisiones y entorno reproducible; P1 adaptador de solo lectura; P2 comandos reales confirmados; P3 biblioteca/dispositivos/configuración; P4 fiabilidad/datos; P5 distribución/actualizaciones/soporte. Cada prioridad tiene responsables sugeridos y criterio de cierre.
- **Validaciones:** dart analyze sin problemas; suite completa: 31 pruebas aprobadas y 1 integración de proceso omitida por condición existente. Cinco documentos de entrada comprobados sin enlaces locales rotos. Formato Dart y revisión de espacios aplicados.
- **Pendientes:** acordar protocolo/capacidades con el motor, adaptar e inyectar datos reales, probar audio físico, preparar paquetes firmados y operación. No se presenta el contrato como una integración implementada.
- **Estado:** Etapa 10 completada. Se cierran las etapas de UI acordadas; cualquier integración o publicación requiere un alcance posterior explícito.

## Corrección visual posterior a las etapas

- **Solicitud:** corregir la distancia entre el diseño de referencia y la UI que abre el ejecutable Windows.
- **Causa comprobada:** EngineDashboard escogía el layout anterior cuando UTRACK_TEST=false. La UI nueva solo aparecía con modo test.
- **Corrección:** el arranque normal abre UtrackShell también sin modo test. La vista local anterior queda accesible en Ajustes junto con configuración/actividad; el código de layout anterior permanece como opción explícita legacyLayout para compatibilidad. No se cambian servicios, bridge, motor o credenciales.
- **Origen de datos:** header y sidebar pueden mostrar el estado real recibido en escritorio; plano, zonas y reproductor permanecen demostrativos, con rótulo visible. No se conectaron controles simulados al audio ni se fabricaron confirmaciones de producción.
- **Rediseño:** negro carbón, bordes y superficies con profundidad sutil, marca circular metálica, sidebar más cercana a la referencia, plano isométrico v2, marcadores metálicos y tarjetas flotantes de volumen. Perilla con graduaciones, cuerpo metálico y volumen inferior; panel compacto con fuente, canales y canción. Reproductor fijo con menos texto auxiliar repetido.
- **Recursos:** nuevo assets/images/zone_floor_plan_v2.png generado con imagegen integrado; original conservado. Solo el plano es una imagen, los controles siguen siendo widgets Flutter.
- **Archivos principales:** engine_dashboard.dart, layout/utrack_shell.dart y utrack_sidebar.dart, design/ui_tokens.dart, widgets/metal_dial.dart (nuevo), zone_map.dart, selected_zone_panel.dart, volume_knob.dart, section_card.dart y player_bar.dart; registro de asset en pubspec y pruebas/capturas adaptadas.
- **Validaciones:** suite de 31 pruebas aprobada con 1 integración omitida; verificación adicional final de capturas y acceso a Ajustes: 8 pruebas aprobadas. Análisis Dart sin problemas. Capturas en cinco tamaños y con texto ampliado/movimiento reducido; referencia final build/previews/stage9-1672x941.png.
- **Distribución:** nuevo paquete Windows release con UTRACK_TEST=false y motor 0.8.0 existente. Debe distinguirse del ZIP anterior que abría la vista antigua.

### Prompt del plano v2 (imagegen integrado)

High-end architectural visualization asset for a dark luxury professional audio desktop application. Square image. A fully visible roofless isometric dollhouse apartment, elevated camera around 55 degrees, rotate floor plan about 18 degrees clockwise in image so front edge slants upwards to the right, strongly three dimensional raised outer walls. Footprint fills 90% of image. Four spaces within one coherent open-plan apartment: terrace with dark stone and plants in upper left, warm wood kitchen upper right, beige sectional living room with round black coffee table lower left, long black dining table with chairs lower right. Moody cinematic warm indirect light, champagne highlights, charcoal floor tiles, extremely realistic miniature architectural render, deep shadows, luxurious materials. Background almost black #080b0e with no border. This is a standalone floor plan illustration, not an app screenshot. NO text, NO buttons, NO dials, NO markers, NO overlays, NO watermark, NO UI. Do not flatten into a top-down floor plan. Preserve isometric angled perspective with the exterior foundation clearly visible.

## Integración de producción posterior a las etapas — 19/10/2026

Alcance ampliado por el usuario: usar parámetros reales del motor existente y retirar simulaciones de producción. No crear habitaciones, canciones, dispositivos ni métricas de ejemplo; dejar campos ausentes preparados. El plano sigue siendo ilustrativo y solo sitúa las zonas recibidas.

- AudioViewState separa presentación de origen; EngineViewState transforma reportes reales y ZonePreviewState queda reservado para test explícito.
- Configuración, servidor/token, inspección e inicio/parada utilizan el bridge existente. El repositorio music-engine no se modifica.
- Solo lectura para controles de zona no admitidos por el protocolo desktop; datos ausentes permanecen desconocidos, sin temporizador de reproducción ni métricas calculadas.
- Selección por ID, cero zonas, errores recuperables, frescura y limpieza de listeners/procesos cubiertos por pruebas.
- Documentación vigente: docs/PRODUCCION.md, ARQUITECTURA.md e INTEGRACION.md. Las descripciones de simulación en etapas anteriores son históricas.

Validación final de integración: dart analyze sin incidencias; suite completa 37 correctas y 1 opt-in omitida en la suite; esa prueba de proceso se ejecutó por separado con ENGINE_BRIDGE_TEST=1 y pasó. Compilación Windows release UTRACK_TEST=false correcta. Paquete completo verificado: Releases/Utrack-Desktop-0.1.0-windows-x64-engine-real.zip. No se conectó al servidor operativo ni se probaron sus credenciales o el audio físico.

## Conexiones de reproducción Desktop — 19/10/2026

Alcance acotado por el usuario: conectar a Desktop las capacidades existentes de reproducción Go y documentar las demás APIs, sin implementarlas. Se añadieron pausa, reanudar, siguiente/anterior y selección de canción asignada; Biblioteca muestra canciones ID por zona. Motor 0.8.1 anuncia capacidades opcionales del protocolo 1 y recibe solicitudes correlacionadas por stdin. Flutter espera confirmación sin actualizar el estado de reproducción por anticipado. Los comandos remotos conservan su diario; los locales se deduplican en memoria por sesión.

Backend Laravel inspeccionado para documentar rutas y archivos; sin modificaciones. Documento aparte: docs/CONEXIONES_DESKTOP_Y_APIS_PENDIENTES.md. Regresión Go completa correcta, análisis Dart limpio y 40 pruebas Flutter correctas; prueba del ejecutable nativo ejecutada aparte. Pendiente validación con servidor/token operativo y hardware real.

## Volumen local Desktop — 19/10/2026

Motor 0.8.2: capacidad volume y parámetro entero 0–100 conectado a perilla/sliders Flutter. Agrupación de solicitudes 200 ms, confirmación del motor y override local hasta nueva revisión del servidor o reinicio. Snapshot Desktop muestra volumen efectivo; heartbeat conserva volumen configurado para respetar el contrato Laravel existente. Sin cambios de backend. Detalle: docs/VOLUMEN_DESKTOP.md. Por petición del usuario, no se ejecutaron pruebas; solo compilación release Go/Flutter.

Compilación Go 0.8.2 correcta. Flutter Windows release UTRACK_TEST=false compilado en C:/Develop/ENGINE/.builds/utrack-volume-082 por desaparición de temporales en el árbol original. Paquete completo: Releases/Utrack-Desktop-0.1.0-windows-x64-volumen-conectado.zip. No se ejecutaron tests ni pruebas de audio.
