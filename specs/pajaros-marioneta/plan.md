# Implementation Plan: Pájaros Marioneta — Animación de entrada/salida (F4)

**Date**: 2026-02-23
**Spec**: [spec.md](./spec.md)

## Summary

Sacar la lógica de pájaros de `parallax_manager.gd` y crear un `BirdsController` independiente
que maneja: creación de siluetas con `Line2D` (hilo), animación de descenso/ascenso con `Tween`,
y desplazamiento horizontal manual en `_process`. La señal `birds_toggled` y la tecla F4 no
cambian.

## Archivos afectados

```text
scripts/effects/birds_controller.gd    ← NUEVO
scenes/effects/birds_controller.tscn   ← NUEVO
scenes/main.tscn                       ← modificar: añadir instancia BirdsController
scripts/world/parallax_manager.gd      ← modificar: eliminar lógica de pájaros
```

---

## Phase B: Pájaros Marioneta — US1 + US2 + US3

**Goal**: Los pájaros descienden animados con hilos visibles al activar F4 y ascienden al desactivar.

**Independent Test**: F5 → presionar F4 → pájaros bajan desde arriba con animación suave, cada
uno con un hilo visible. Presionar F4 → pájaros suben y desaparecen por arriba.

### Implementación

- [ ] T-BIRD-001 [US1+US2+US3] Crear `scripts/effects/birds_controller.gd`:
  ```
  class_name BirdsController extends Node2D
  @export var bird_count: int = 8
  @export var rest_y: float = -150.0     # posición Y estable (relativa al centro de pantalla)
  @export var scroll_speed: float = 120.0
  @export var anim_duration: float = 1.0

  var _active: bool = false
  var _container: Node2D = null         # contiene todos los pájaros
  var _tween: Tween = null

  func _ready() -> void:
      GameManager.birds_toggled.connect(_on_birds_toggled)

  func _process(delta: float) -> void:
      if _container == null: return
      # Desplazamiento horizontal en loop
      _container.position.x -= scroll_speed * delta
      var mirror_width := 1280.0  # ancho de la "tira" de pájaros
      if _container.position.x < -mirror_width:
          _container.position.x += mirror_width

  func _on_birds_toggled(active: bool) -> void:
      _active = active
      if _tween: _tween.kill()
      if active:
          _create_birds()
          var vp_hh := get_viewport_rect().size.y * 0.5
          _container.position.y = -vp_hh - 100.0   # arriba, fuera de pantalla
          _tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
          _tween.tween_property(_container, "position:y", rest_y, anim_duration)
      else:
          if _container == null: return
          var vp_hh := get_viewport_rect().size.y * 0.5
          _tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
          _tween.tween_property(_container, "position:y", -vp_hh - 100.0, anim_duration)
          _tween.tween_callback(func(): _destroy_birds())

  func _create_birds() -> void:
      _container = Node2D.new()
      _container.z_index = 1
      add_child(_container)
      var xs := _spread_xs(bird_count, 1280.0)
      for x in xs:
          var bird := _make_bird_marionette()
          bird.position = Vector2(x - 640.0, 0.0)   # centrado
          _container.add_child(bird)

  func _destroy_birds() -> void:
      if _container: _container.queue_free()
      _container = null

  func _spread_xs(n: int, total_width: float) -> Array:
      var xs := []
      for i in n:
          xs.append(total_width * i / n + randf() * 60.0)
      return xs

  func _make_bird_marionette() -> Node2D:
      var root := Node2D.new()
      # Silueta del pájaro (Polygon2D)
      var bird := Polygon2D.new()
      bird.polygon = PackedVector2Array([
          Vector2(-14, 5), Vector2(-7, 0), Vector2(0, -4),
          Vector2(7, 0), Vector2(14, 5),
          Vector2(9, 7), Vector2(0, 3), Vector2(-9, 7)
      ])
      bird.color = Color(0.08, 0.08, 0.10, 0.90)
      root.add_child(bird)
      # Hilo (Line2D): desde el pájaro hacia arriba, 700px
      var thread := Line2D.new()
      thread.add_point(Vector2(0, 0))
      thread.add_point(Vector2(0, -700))
      thread.width = 1.0
      thread.default_color = Color(0.15, 0.15, 0.18, 0.65)
      root.add_child(thread)
      return root
  ```

- [ ] T-BIRD-002 [US1] Crear `scenes/effects/birds_controller.tscn`:
  - Raíz: `Node2D` con script `birds_controller.gd`
  - Sin hijos (los pájaros se crean dinámicamente por código)

- [ ] T-BIRD-003 `scenes/main.tscn`: añadir instancia de `birds_controller.tscn`
  como hijo de `GameWorld` (después de `WindEffect` / `VacuumEffect`)

- [ ] T-BIRD-004 `scripts/world/parallax_manager.gd`: eliminar toda la lógica de pájaros:
  - Eliminar variable `_bird_layer: ParallaxLayer`
  - Eliminar función `toggle_birds(active: bool)`
  - Eliminar función `_create_bird_layer()`
  - Eliminar función `_make_bird_shape()`
  - Eliminar línea `GameManager.birds_toggled.connect(toggle_birds)` en `_ready()`

**Checkpoint**: F4 → pájaros descienden suavemente con hilo visible, se desplazan horizontalmente.
F4 → pájaros ascienden y desaparecen.

---

## Dependencies

- **Prerequisito**: Phase 7 completada (GameManager.birds_toggled conectado) ✅
- `main_scene.gd` no necesita cambios — `BirdsController` se conecta directamente a `GameManager`
