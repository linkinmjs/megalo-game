# Implementation Plan: Director — Control de Shaders de Pantalla

**Date**: 2026-02-23
**Spec**: [spec.md](./spec.md)

---

## Summary

El `GameManager` ya gestiona un CanvasLayer con un único shader VHS fijo. Esta feature
extiende ese sistema para soportar **3 shaders intercambiables** (VHS, aberración
cromática, pixelado) con un `boost` uniform por shader que el director controla en
tiempo real manteniendo F7 presionado. La navegación (F6/F8) reemplaza el material
activo en el ColorRect existente.

---

## Technical Context

**Language/Version**: GDScript / Godot 4.6
**Primary Dependencies**: Godot 4.6 nativo (ShaderMaterial, canvas_item shaders)
**Storage**: N/A
**Testing**: Prueba manual en editor (F5) + verificación visual por pantalla
**Target Platform**: PC (Windows)
**Performance Goals**: 60 fps estables durante todo el gameplay con shader activo
**Constraints**: El shader se aplica sobre `CanvasLayer` layer=50 (ya existe en GameManager)

---

## Árbol de nodos (sin cambios de escena)

El sistema reutiliza la infraestructura del CanvasLayer ya creado por `GameManager`:

```
GameManager (Autoload — modificado)
└── _vhs_layer (CanvasLayer, layer=50)  ← renombrar a _shader_layer internamente
    └── _shader_rect (ColorRect)        ← era _vhs_rect; ahora puede tener cualquier material
```

No se crean nodos nuevos en escena. Solo se agregan materiales nuevos al array interno.

---

## Señales involucradas

| Señal | Definida en | Escuchada por |
|-------|-------------|--------------|
| `shader_changed(index: int)` | `GameManager` | *(reservada para uso futuro — no se conecta en esta feature)* |

---

## @exports configurables

| Variable | Tipo | Nodo/Script | Para qué |
|----------|------|------------|----------|
| `boost_rise_speed` | `float` | `director_controller.gd` | Velocidad de subida del boost (unidades/s). Default 0.7 → llega al max en ~1.4s |
| `boost_fall_speed` | `float` | `director_controller.gd` | Velocidad de bajada al soltar F7. Default 2.0 → vuelve al base en ~0.5s |

---

## Parámetros de los shaders

### VHS (modificado)
Agrega `uniform float boost = 0.0` que amplifica internamente:
- `glitch_frequency` base → max (1.0 → 8.0)
- `glitch_strength` base → max (0.010 → 0.06)
- `chromatic_spike` base → max (0.006 → 0.025)

### Aberración cromática (nuevo)
- `uniform float separation_base = 0.004` — split RGB sutil siempre presente
- `uniform float separation_max = 0.035` — split extremo al potenciar
- `uniform float boost = 0.0` — interpola entre base y max

### Pixelado (nuevo)
- `uniform float pixel_size_base = 3.0` — pixelado sutil
- `uniform float pixel_size_max = 20.0` — pixeles muy grandes
- `uniform float boost = 0.0` — interpola entre base y max
- Usa `SCREEN_PIXEL_SIZE` de Godot para calcular el UV pixelado sin uniforms de resolución

---

## Phase 1 — Shaders (bloqueante para todo lo demás)

**Propósito**: Crear los 3 archivos `.gdshader` con sus uniforms de boost. Sin estos,
`GameManager` no puede crear los materiales.

- [x] T001 [P] [US3] Agregar `uniform float boost` a `vhs_effect.gdshader` → amplifica glitch_frequency/strength/chromatic_spike internamente con `mix()` → `assets/shaders/vhs_effect.gdshader`
- [x] T002 [P] [US3] Crear `assets/shaders/chromatic_aberration.gdshader` — split RGB controlado por `boost`, screen_texture hint, `separation_base` + `separation_max` → `assets/shaders/chromatic_aberration.gdshader`
- [x] T003 [P] [US3] Crear `assets/shaders/pixelate.gdshader` — pixelado con `pixel_size` calculado desde `boost` + `SCREEN_PIXEL_SIZE` → `assets/shaders/pixelate.gdshader`

**Checkpoint T001–T003**: Abrir el shader en el editor de Godot → asignar manualmente a un ColorRect → mover el uniform `boost` en el Inspector → verificar que el efecto cambia visualmente de sutil a exagerado.

---

## Phase 2 — API de GameManager (bloqueante para el director)

**Propósito**: Extender `GameManager` para mantener los 3 materiales y exponer la API
que el director usará.

- [x] T004 [P] [US1, US2, US3] Ampliar `game_manager.gd`:
  - Reemplazar la carga de VHS hardcodeada por un array `_shader_materials: Array[ShaderMaterial]` con los 3 materiales
  - Agregar `_shader_index: int = 0`
  - Agregar `signal shader_changed(index: int)`
  - Agregar `func set_active_shader(index: int)` → reemplaza `_shader_rect.material`, resetea boost a 0.0, emite `shader_changed`
  - Agregar `func apply_shader_boost(t: float)` → llama `_shader_rect.material.set_shader_parameter("boost", t)`
  - El shader inicial sigue siendo VHS (índice 0) para no romper el comportamiento existente
  → `scripts/autoloads/game_manager.gd`

**Checkpoint T004**: Correr el juego → verificar que el efecto VHS sigue visible exactamente igual que antes (ningún cambio de comportamiento visible en este punto).

---

## Phase 3 — US1: Navegación entre shaders (F6 / F8)

**Objetivo**: El director puede cambiar el shader activo navegando linealmente por la lista.

**Independent Test**: Abrir `scenes/main.tscn` → presionar F8 → verificar que el efecto VHS desaparece y aparece la aberración cromática → presionar F8 → aparece el pixelado → presionar F8 → nada cambia → presionar F6 → vuelve a aberración → F6 → VHS → F6 → nada.

- [x] T005 [P] [US1] Ampliar `director_controller.gd`:
  - Agregar `_shader_index: int = 0` (mirror local del índice)
  - Handler `KEY_F6`: `_shader_index = max(_shader_index - 1, 0)` → `GameManager.set_active_shader(_shader_index)`
  - Handler `KEY_F8`: `_shader_index = min(_shader_index + 1, 2)` → `GameManager.set_active_shader(_shader_index)`
  - Dentro del guard `event.pressed and not event.echo` existente
  → `scripts/director/director_controller.gd`

**Checkpoint T005**: Test descrito en Independent Test arriba.

---

## Phase 4 — US2: Potenciado temporal con F7

**Objetivo**: Mantener F7 sube el `boost` gradualmente; soltar lo baja gradualmente.

**Independent Test**: Abrir `scenes/main.tscn` → con cualquier shader activo, mantener F7 ~2s → verificar que el efecto se exagera progresivamente → soltar → el efecto vuelve suavemente al estado base en ≥ 0.5s.

- [x] T006 [P] [US2] Ampliar `director_controller.gd`:
  - Agregar `@export var boost_rise_speed: float = 0.7` y `@export var boost_fall_speed: float = 2.0`
  - Agregar `var _boost_level: float = 0.0`
  - Agregar `func _process(delta: float)`:
    - `var held := Input.is_key_pressed(KEY_F7)`
    - Si `held`: `_boost_level = min(_boost_level + boost_rise_speed * delta, 1.0)`
    - Si no: `_boost_level = max(_boost_level - boost_fall_speed * delta, 0.0)`
    - `GameManager.apply_shader_boost(_boost_level)`
  - Reset del boost al cambiar shader: en los handlers F6/F8, hacer `_boost_level = 0.0`
  → `scripts/director/director_controller.gd`

**Checkpoint T006**: Test descrito arriba. Adicionalmente: potenciar VHS, presionar F8 (cambia a aberración cromática), verificar que el boost vuelve a 0 y el nuevo shader empieza en su valor base.

---

## Phase 5 — US3: Verificación de identidad visual

**Objetivo**: Confirmar que los 3 shaders son visualmente distinguibles y que su
comportamiento de boost es apropiado.

*No hay tareas de código en esta fase — depende de T001–T003 completados.*

**Checkpoint US3**: Abrir `scenes/main.tscn` con el juego corriendo → navegar por los 3 shaders con F8 y verificar:
- Shader 1 (VHS): jitter, glitches ocasionales, aberración cromática sutil ✓
- Shader 2 (Aberración): imagen con split de colores RGB notablemente separados ✓
- Shader 3 (Pixelado): imagen con aspecto retro, píxeles visibles ✓

Luego en cada shader: mantener F7 y verificar que el efecto se exagera de forma distinta y característica para cada uno.

---

## Dependencies & Execution Order

```
T001 ──┐
T002 ──┤→ T004 → T005 → T006
T003 ──┘
```

- **T001, T002, T003** pueden escribirse en paralelo (son archivos independientes)
- **T004** requiere T001–T003 para cargar los shaders
- **T005** requiere T004 para llamar `GameManager.set_active_shader()`
- **T006** requiere T005 (extiende el mismo archivo) y T004

---

## Notas de implementación

- `Input.is_key_pressed(KEY_F7)` en `_process()` es más simple que interceptar key-release en `_unhandled_input`; no requiere cambiar el guard existente.
- Los 3 materiales se cargan en `_ready()` de GameManager y se mantienen en memoria (tamaño mínimo). No se recargan al cambiar shader — solo se reemplaza `.material` en el ColorRect.
- El shader de pixelado usa `SCREEN_PIXEL_SIZE` (disponible en canvas_item shaders de Godot 4) para calcular el UV pixelado sin necesitar un uniform de resolución de pantalla — esto simplifica el setup.
- Si `set_active_shader()` recibe el mismo índice que el activo, no hace nada (evita reset innecesario del boost si el director presiona F6/F8 en los extremos).
