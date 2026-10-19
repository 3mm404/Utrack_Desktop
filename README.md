# UTRACK Engine / Utrack Desktop

Aplicación Flutter para administrar un motor de audio local. La interfaz profesional desarrollada en las etapas 0–10 es una **vista de pruebas**, con datos simulados y sin audio real.

## Leer primero

| Documento | Contenido |
| --- | --- |
| [Arquitectura](docs/ARQUITECTURA.md) | Carpetas, flujo de datos, responsabilidades y límites actuales |
| [Integración](docs/INTEGRACION.md) | Contrato tipado propuesto, brechas del protocolo y conexión futura |
| [Mantenimiento y actualizaciones](docs/MANTENIMIENTO.md) | Entornos, pruebas, versiones, distribución y recuperación |
| [Plan de trabajo](docs/ROADMAP.md) | Prioridades, responsables sugeridos y criterios de entrega |
| [Registro de etapas](DESARROLLO_UI_POR_ETAPAS.md) | Alcance aprobado, decisiones, validaciones y prompts de recursos |

## Ejecutar la UI de pruebas

```sh
flutter pub get
flutter run -d chrome --dart-define=UTRACK_TEST=true
```

En escritorio usa `-d windows` o, desde un Mac preparado, `-d macos`. Web siempre utiliza modo test. En Windows el CMake actual también exige el archivo `windows/engine/engine.exe` para empaquetar, incluso con la bandera test; consulta Mantenimiento antes de compilar.

```sh
flutter analyze
flutter test
flutter build web --release --dart-define=UTRACK_TEST=true
```

Salida web: `build/web`. Capturas regenerables: `flutter test test/ui_visual_review_test.dart`, en `build/previews/`.

## Estado real del producto

- UI: plano, zonas, perilla, dispositivo, métricas y reproductor adaptables; estado simulado compartido en memoria.
- Escritorio sin `UTRACK_TEST=true`: conserva la vista anterior y `ProcessEngineBridge` para inspección, configuración e inicio/parada del ejecutable local. No activa automáticamente la UI nueva.
- Hay dos simulaciones distintas: `DemoEngineBridge` alimenta el controlador anterior; `ZonePreviewState` alimenta la UI nueva. No están sincronizadas.
- Etapa 10: contrato de presentación declarado en `lib/views/contracts/audio_ui_port.dart`. Aún no tiene adaptadores ni está conectado a los widgets.
- Motor, servidor, biblioteca real, persistencia de la nueva UI y actualizador: pendientes de integración/desarrollo según las guías.

No se debe presentar el modo test como reproducción operativa ni distribuir sus métricas como mediciones reales. El alcance realizado sigue siendo UI y preparación documental; el backend y el motor no se modificaron en estas etapas.
