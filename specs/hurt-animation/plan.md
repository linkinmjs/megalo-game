# Implementation Plan: Nueva animación de golpe / hurt (knockback)

**Date**: 2026-02-23
**Spec**: [spec.md](./spec.md)

## Summary

Reemplazar la animación de squish/stretch del knockback (escala del `visual_root`) por un efecto
de tres fases: flash de color rojo en `visual_root.modulate`, freeze de input (~0.3s), e impulso
de velocidad moderado. Los cambios se concentran exclusivamente en `balloon_controller.gd`.

## Archivos afectados

```text
scripts/player/balloon_controller.gd    ← único archivo modificado
```

---

## Phase C: Nueva hurt animation — US1 + US2 + US3

**Goal**: El globo muestra un flash rojo + freeze de input al recibir un golpe, sin squish/stretch.

**Independent Test**: F5 → dejar que un obstáculo golpee el globo → verificar que el globo
se pone rojo brevemente, no responde al input por ~0.3s, y no cambia de tamaño.

### Implementación

- [ ] T-HURT-001 `balloon_controller.gd`: agregar variables de estado de golpe:
  ```gdscript
  var _hit_active: bool = false  # true durante el freeze de input
  var _hit_timer: SceneTreeTimer = null
  ```
  Eliminar `var _squish_tween: Tween = null`

- [ ] T-HURT-002 `balloon_controller.gd`: en `_handle_input(delta)`, agregar al inicio:
  ```gdscript
  if _hit_active:
      # Gravedad sigue activa durante el freeze — solo bloquear input directo
      velocity.y += gravity * delta
      velocity.y = clamp(velocity.y, -max_vertical_speed, max_vertical_speed)
      return
  ```

- [ ] T-HURT-003 `balloon_controller.gd`: reemplazar `_play_squish()` por `_play_hit_effect()`:
  ```gdscript
  func _play_hit_effect() -> void:
      # Cancelar hit previo si llegó otro golpe antes de que terminara
      _hit_active = true
      # Flash rojo inmediato en visual_root (afecta globo + calavera)
      visual_root.modulate = Color(1.0, 0.15, 0.15)
      # Fade back al color normal en 0.4s
      var tween := create_tween()
      tween.tween_property(visual_root, "modulate", Color.WHITE, 0.4)
      # Desactivar freeze después de 0.3s via timer de escena
      _hit_timer = get_tree().create_timer(0.3)
      _hit_timer.timeout.connect(func(): _hit_active = false)
  ```

- [ ] T-HURT-004 `balloon_controller.gd`: actualizar `apply_knockback()`:
  ```gdscript
  func apply_knockback(direction: Vector2, force: float) -> void:
      velocity += direction.normalized() * force
      _play_hit_effect()
  ```
  Eliminar la llamada a `_play_squish()`.

- [ ] T-HURT-005 `balloon_controller.gd`: eliminar la función `_play_squish()` completa
  (ya reemplazada por `_play_hit_effect()`).

**Checkpoint**: Obstáculo golpea al globo → el globo se tiñe de rojo y vuelve a blanco en ~0.4s,
no responde a teclas por ~0.3s, no cambia de escala. Al recuperarse, control vuelve completamente.

---

## Dependencies

- **Prerequisito**: Phase 6 completada (apply_knockback implementado) ✅
- No hay dependencias cruzadas con otras features pendientes
- Cambio aislado: solo `balloon_controller.gd`, 0 archivos más
