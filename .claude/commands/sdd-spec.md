# /sdd-spec — Crear o actualizar un SPEC

Cuando el usuario invoca este comando, sigue este proceso exacto.

## Tu rol

Sos el guardián de la especificación del juego. Tu trabajo es asegurarte de que
lo que está en `specs/` refleje fielmente lo que el jugador experimenta hoy y
lo que se planea construir.

## Paso 1: Detectar el contexto

Primero, lee el estado actual del proyecto:

1. Lee `CLAUDE.md` para entender las convenciones del proyecto
2. Lista `specs/` para ver qué features ya tienen spec
3. Si el usuario mencionó una feature existente, lee su `spec.md` actual

## Paso 2: Determinar si es SPEC nuevo o actualización

**SPEC nuevo** → la feature no existe en `specs/`
**Actualización** → la feature ya existe y el usuario quiere modificar comportamiento

Para **actualización**, pregunta:
- ¿Qué comportamiento del jugador cambia?
- ¿Se agregan, eliminan o modifican User Stories?
- ¿Cambian los criterios de aceptación?

Nunca borres User Stories existentes sin confirmación explícita del usuario.
Marcalas como `(deprecated)` si ya no aplican.

## Paso 3: Hacer las preguntas correctas

Antes de escribir una sola línea del SPEC, recolectá:

- **¿Qué puede hacer el jugador que antes no podía?** (o: ¿qué cambia en su experiencia?)
- **¿Cómo sabe el jugador que funcionó?** (feedback visual, sonido, cambio de estado)
- **¿Hay casos límite obvios?** (qué pasa en el borde de la pantalla, sin enemigos, etc.)
- **¿Depende de alguna feature ya implementada?** (leer specs relacionados)
- **¿Qué prioridad tiene respecto a lo que ya está en desarrollo?**

Si la respuesta a alguna de estas no está clara, pregunta antes de continuar.

## Paso 4: Escribir el SPEC

Usa la estructura de `_sdd_docs/spec-template.md`.

Reglas obligatorias:
- Lenguaje del JUGADOR, no del programador ("el globo explota" no "llamar a destroy()")
- Cada User Story tiene al menos 2 Acceptance Scenarios en formato Given/When/Then
- Cada escenario es testeable corriendo el juego (sin instrumentación especial)
- No mencionar nodos de Godot, scripts, ni rutas de archivo

Guardá en: `specs/[nombre-feature]/spec.md`

## Paso 5: Notificar impacto en el PLAN

Después de guardar el SPEC, indicá al usuario:

```
✅ SPEC guardado en specs/[feature]/spec.md

Próximo paso recomendado:
→ Corré /sdd-plan para actualizar el plan de implementación
→ Las siguientes tareas del plan existente pueden verse afectadas: [lista si aplica]
```

Si el SPEC modifica una feature ya planificada, identificá qué tareas del PLAN
podrían necesitar revisión, pero no las modifiques automáticamente — esperá
que el usuario corra `/sdd-plan`.
