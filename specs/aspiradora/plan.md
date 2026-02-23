# Implementation Plan: Aspiradora — Efecto de succión (reemplaza viento F3)

**Date**: 2026-02-23
**Spec**: [spec.md](./spec.md)

## Summary

Reemplazar el `WindEffect` (partículas que empujan al globo hacia la derecha) por una
`VacuumEffect` (aspiradora gigante que asoma desde el borde izquierdo y atrae al globo
hacia ella). La señal `wind_toggled` y la función `receive_wind_force` del globo no cambian —
solo cambia el signo de la fuerza emitida (negativo = hacia la izquierda) y el visual del efecto.

## Archivos afectados

```text
scripts/effects/vacuum_effect.gd          ← NUEVO (reemplaza wind_effect.gd)
scenes/effects/vacuum_effect.tscn         ← NUEVO (reemplaza wind_particles.tscn)
scenes/main.tscn                          ← modificar: swapear instancia
scripts/world/main_scene.gd               ← modificar: reconectar señal
scripts/effects/wind_effect.gd            ← ELIMINAR (deprecated)
scenes/effects/wind_particles.tscn        ← ELIMINAR (deprecated)
```

---

## Phase A: Aspiradora — US1 + US2 + US3

**Goal**: Reemplazar el WindEffect completo por la aspiradora con fuerza de succión y partículas.

**Independent Test**: F5 → presionar F3 → verificar que una forma placeholder aparece desde
la izquierda, el globo deriva hacia la izquierda, y hay partículas que van hacia la izquierda.
Presionar F3 de nuevo → todo desaparece.

### Implementación

- [ ] T-ASP-001 [US1+US2] Crear `scripts/effects/vacuum_effect.gd`:
  ```
  class_name VacuumEffect extends Node2D
  signal suction_force_changed(force: float)
  @export var suction_force: float = 120.0   # fuerza de atracción hacia la izquierda
  @export var anim_duration: float = 0.35     # duración del slide de entrada/salida
  @onready var _particles: CPUParticles2D = $SuctionParticles
  var _active: bool = false
  var _tween: Tween = null
  func _ready():
      # Posicionar la aspiradora completamente fuera de pantalla a la izquierda
      # La boca asoma ~80px dentro de pantalla en X cuando está activa
      var vp_half_w := get_viewport_rect().size.x * 0.5
      position.x = -vp_half_w - 120.0   # fuera de pantalla
      position.y = 0.0
      _particles.emitting = false
      GameManager.wind_toggled.connect(_on_wind_toggled)
  func _on_wind_toggled(active: bool) -> void:
      _active = active
      if _tween: _tween.kill()
      _tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
      var vp_half_w := get_viewport_rect().size.x * 0.5
      var target_x := (-vp_half_w + 80.0) if active else (-vp_half_w - 120.0)
      _tween.tween_property(self, "position:x", target_x, anim_duration)
      _particles.emitting = active
      suction_force_changed.emit(-suction_force if active else 0.0)
  ```

- [ ] T-ASP-002 [US1+US3] Crear `scenes/effects/vacuum_effect.tscn`:
  - Raíz: `Node2D` (VacuumEffect) con script `vacuum_effect.gd`
  - Hijo `VacuumBody` (`Polygon2D`): silueta placeholder de la aspiradora
    (rectángulo ~200×120, boca circular abierta hacia la derecha, color gris oscuro)
  - Hijo `SuctionParticles` (`CPUParticles2D`): partículas de succión
    - `emission_shape` = Box, `emission_box_extents = Vector2(640, 300)` (pantalla completa)
    - `direction = Vector2(-1, 0)`, `spread = 15.0`
    - `initial_velocity_min = 400.0`, `initial_velocity_max = 700.0`
    - `gravity = Vector2(0, 0)`
    - `amount = 150`, `lifetime = 0.9`, `lifetime_randomness = 0.3`
    - `scale_amount_min = 1.5`, `scale_amount_max = 4.0`
    - `color = Color(0.85, 0.90, 1.0, 0.75)`
    - `local_coords = false`

- [ ] T-ASP-003 `scenes/main.tscn`: reemplazar instancia de `wind_particles.tscn`
  (nodo `WindEffect`) con instancia de `vacuum_effect.tscn` (renombrar nodo a `VacuumEffect`)

- [ ] T-ASP-004 `scripts/world/main_scene.gd`:
  - Cambiar `@onready var wind_effect: WindEffect = $GameWorld/WindEffect`
    → `@onready var vacuum_effect: VacuumEffect = $GameWorld/VacuumEffect`
  - Cambiar `wind_effect.wind_force_changed.connect(balloon.receive_wind_force)`
    → `vacuum_effect.suction_force_changed.connect(balloon.receive_wind_force)`

- [ ] T-ASP-005 Eliminar `scripts/effects/wind_effect.gd` y `scenes/effects/wind_particles.tscn`
  (archivos deprecated — confirmar que no hay más referencias antes de borrar)

**Checkpoint**: F3 → aspiradora entra desde la izquierda, globo es atraído hacia ella,
partículas van hacia la izquierda. F3 → aspiradora sale, fuerza cesa.

---

## Dependencies

- **Prerequisito**: Phase 6 completada (balloon_controller.gd con `receive_wind_force`)  ✅
- **Prerequisito**: Phase 7 completada (GameManager.wind_toggled conectado) ✅
- `balloon_controller.gd` no necesita cambios — `receive_wind_force` ya acepta valores negativos
