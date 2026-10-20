# Integración con el engine

- engine_api_catalog.dart: operaciones locales y capacidades de consulta conocidas.
- engine_api_request.dart: solicitud tipada, validación y serialización JSON.
- EngineController.executeEngineRequest: coordinación y confirmación.

Los widgets no construyen JSON ni abren conexiones. Las rutas HTTP del backend pertenecen al cliente Go; este directorio no contiene una API administrativa ficticia.

Guía: docs/AGREGAR_APIS_Y_FUNCIONES.md, desde la raíz del proyecto Flutter.
