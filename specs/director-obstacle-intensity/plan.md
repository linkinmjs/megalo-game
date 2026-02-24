# Implementation Plan: Director — Control de Intensidad de Obstáculos

**Date**: 2026-02-23
**Spec**: [spec.md](./spec.md)

---

## Summary

El `ObstacleSpawner` actual tiene un `Timer` que corre automáticamente cada 4s desde
`_ready()` y responde al evento one-shot `"spawn_obstacle"` del director. Esta feature
reemplaza ese comportamiento: el timer no arranca solo, y F5 controla la frecuencia
en 4 escalones. Double-tap en F5 detiene todo. El `director_controller.gd` gestiona
la lógica de nivel y double-tap; el `ObstacleSpawner` recibe una señal con el nivel
y ajusta su timer.

---

## Technical Context

**Language/Version**: GDScript / Godot 4.6
**Testing**: Prueba manual en editor (F5)
**Constraints**: No romper la señal `event_director` existente (la usan otros sistemas)

---

## Estado previo (T030 — ahora supersedido)

```
# director_controller.gd (actual)
KEY_F5: GameManager.event_director.emit("spawn_obstacle")

# obstacle_spawner.gd (actual)
_timer.start()  # ← arranca automáticamente en _ready(), cada 4s
_on_director_event("spawn_obstacle") → _spawn_random()
```

---

## Árbol de nodos (sin cambios de escena)

No se crean nodos nuevos. Los cambios son solo en scripts existentes.

```
ObstacleSpawner (Node2D) ← obstacle_spawner.gd (modificado)
└── Timer  ← ya existe; ahora inicia PARADO y se controla por señal
```

---

## Señales involucradas

| Señal | Definida en | Escuchada por |
|-------|-------------|--------------|
| `obstacle_intensity_changed(level: int)` | `GameManager` (nueva) | `ObstacleSpawner` |

La señal `event_director(String)` existente **se mantiene** sin cambios para no afectar
otros usos futuros. Solo se deja de usar `"spawn_obstacle"` como evento de F5.

---

## @exports configurables

| Variable | Tipo | Nodo/Script | Para qué |
|----------|------|------------|----------|
| `double_tap_window` | `float` | `director_controller.gd` | Ventana de detección double-tap (s). Default 0.5 |

Los intervalos por nivel son constantes en el script (no exports), dado que son parte
del diseño del director, no del spawner.

---

## Lógica de double-tap en `director_controller.gd`

```gdscript
const INTENSITY_INTERVALS: Array[float] = [6.0, 3.0, 1.5, 0.75]  # índice = nivel-1
@export var double_tap_window: float = 0.5

var _intensity_level: int = 0
var _last_f5_press: float = -1.0   # -1 = sin press previo

# En _unhandled_input, handler KEY_F5:
var now := Time.get_ticks_msec() / 1000.0
if _last_f5_press >= 0.0 and now - _last_f5_press < double_tap_window:
    # double-tap → reset
    _intensity_level = 0
    _last_f5_press = -1.0
    GameManager.obstacle_intensity_changed.emit(0)
else:
    # press normal (o primero)
    _last_f5_press = now
    if _intensity_level < 4:
        _intensity_level += 1
        GameManager.obstacle_intensity_changed.emit(_intensity_level)
    # en nivel 4: _last_f5_press se actualiza igual → permite double-tap reset
```

Casos cubiertos:
- Nivel 4 + press → nada (FR-NEW-05), pero `_last_f5_press` actualizado → permite double-tap reset
- Double-tap desde cualquier nivel → resetea (double-tap tiene prioridad)
- Triple-tap rápido → primer press sube, segundo reset, `_last_f5_press=-1` → tercero ignorado o inicia nueva secuencia

---

## Lógica en `obstacle_spawner.gd`

```gdscript
# _ready(): NO llamar _timer.start()
# Escuchar señal nueva:
GameManager.obstacle_intensity_changed.connect(_on_intensity_changed)

func _on_intensity_changed(level: int) -> void:
    if level == 0:
        _timer.stop()
    else:
        _timer.wait_time = INTENSITY_INTERVALS[level - 1]  # [6.0, 3.0, 1.5, 0.75]
        _timer.start()
        _spawn_random()   # spawn inmediato como confirmación (FR-NEW-03)
```

---

## Phase 1 — Señal nueva en GameManager

- [x] T-OI-001 [P] Agregar `signal obstacle_intensity_changed(level: int)` a `game_manager.gd` → `scripts/autoloads/game_manager.gd`

---

## Phase 2 — US1 + US2 + US3: Lógica de director (F5)

**Objetivo**: F5 gestiona niveles y double-tap; emite `obstacle_intensity_changed`.

**Independent Test**: Correr juego → verificar que no aparece ningún obstáculo automáticamente → presionar F5 → aparece uno de inmediato y luego cada ~6s → F5 × 3 veces más → frecuencia aumenta notablemente en cada press.

- [x] T-OI-002 [P] [US1, US2, US3] Actualizar `director_controller.gd`:
  - Agregar `const INTENSITY_INTERVALS: Array[float] = [6.0, 3.0, 1.5, 0.75]`
  - Agregar `@export var double_tap_window: float = 0.5`
  - Agregar `var _intensity_level: int = 0` y `var _last_f5_press: float = -1.0`
  - Reemplazar handler `KEY_F5` (actualmente `GameManager.event_director.emit("spawn_obstacle")`) por la lógica de double-tap + escalado descripta arriba
  → `scripts/director/director_controller.gd`

**Checkpoint T-OI-002**: F5 no spawna en modo one-shot. Presionar F5 → un obstáculo aparece. Presionar F5 tres veces más → frecuencia sube en cada press. Presionar F5 dos veces rápido → spawn se detiene.

---

## Phase 3 — US1 + US2 + US3: Spawner responde a la señal

**Objetivo**: El timer del spawner se controla por la señal, no arranca solo.

**Independent Test**: Correr juego → ningún obstáculo aparece solo → F5 → obstáculos empiezan → double-tap F5 → dejan de aparecer.

- [x] T-OI-003 [P] [US1, US2, US3] Actualizar `obstacle_spawner.gd`:
  - Agregar `const INTENSITY_INTERVALS: Array[float] = [6.0, 3.0, 1.5, 0.75]`
  - En `_ready()`: **eliminar** `_timer.start()` (el timer empieza parado)
  - En `_ready()`: conectar `GameManager.obstacle_intensity_changed.connect(_on_intensity_changed)`
  - Agregar `func _on_intensity_changed(level: int)`:
    - Si `level == 0`: `_timer.stop()`
    - Si `level > 0`: `_timer.wait_time = INTENSITY_INTERVALS[level - 1]` → `_timer.start()` → `_spawn_random()`
  - **Mantener** `_on_director_event` sin cambios (no quitar la conexión existente — puede usarse para otros eventos futuros)
  → `scripts/obstacles/obstacle_spawner.gd`

**Checkpoint T-OI-003** (test completo):
1. Correr juego → ningún obstáculo aparece
2. F5 × 1 → obstáculo inmediato + spawn cada ~6s
3. F5 × 1 → obstáculo inmediato + spawn cada ~3s
4. F5 × 1 → obstáculo inmediato + spawn cada ~1.5s
5. F5 × 1 → obstáculo inmediato + spawn cada ~0.75s
6. F5 × 1 → nada (nivel máximo)
7. F5 × 2 rápido → spawn se detiene; ningún obstáculo nuevo aparece

---

## Dependencies & Execution Order

```
T-OI-001 → T-OI-002 → T-OI-003
```

Las tres tareas son secuenciales: la señal debe existir antes de emitirla, y el spawner
debe poder conectarse a ella.

---

## Notas de implementación

- `_timer.start()` con un nuevo `wait_time` en Godot 4 **reinicia el timer desde cero** — esto es el comportamiento deseado al cambiar de nivel (SC-NEW-04: el nuevo intervalo aplica desde el spawn siguiente).
- `_timer.stop()` en Godot 4 detiene el timer y lo marca como no activo — cualquier `timeout` que estuviera pendiente se cancela (SC-NEW-02).
- El `export var spawn_cooldown` en `obstacle_spawner.gd` queda sin uso funcional después de este cambio. Se puede dejar como dead code sin impacto, o eliminar — se decide al implementar.
- La conexión `GameManager.event_director` para `"spawn_obstacle"` en `obstacle_spawner._ready()` puede eliminarse ya que F5 ya no la emite. Se deja a criterio del implementador si quitar la conexión completa o solo el handler del string `"spawn_obstacle"`.
