# Implementation Plan: Megalo — Globo Aerostático

**Date**: 2026-02-21
**Spec**: [spec.md](./spec.md)

## Summary

Juego 2D en Godot 4.6 con un globo aerostático controlado por mechero (sube/baja por gravedad), scroll de fondo parallax, obstáculos que empujan sin matar al jugador, y un sistema de Director para triggerear eventos visuales en tiempo real durante la grabación del videoclip. Duración: ~2 minutos. Sin game over ni puntuación.

## Technical Context

**Language/Version**: GDScript / Godot 4.6
**Primary Dependencies**: Godot 4.6 (nativo, sin librerías externas)
**Storage**: N/A (no hay datos persistentes)
**Testing**: Prueba manual en editor (F5) y verificación visual
**Target Platform**: PC (Windows, GL Compatibility + D3D12)
**Project Type**: Single (Godot project)
**Performance Goals**: 60 fps estables, sin hitches durante la ejecución de 2 minutos
**Constraints**: Debe poder grabarse en pantalla sin modificar código entre tomas; sin assets de audio inicialmente (placeholder)
**Scale/Scope**: ~10 escenas, ~12 scripts GDScript, 1 shader

## Project Structure

### Documentation (this feature)

```text
specs/megalo-balloon/
├── plan.md              # Este archivo
└── spec.md              # Especificación de qué construir
```

### Source Code (repository root)

```text
scenes/
├── main.tscn                        # Escena raíz del juego
├── player/
│   └── balloon.tscn                 # Globo aerostático (CharacterBody2D)
├── obstacles/
│   ├── obstacle_base.tscn           # Escena base de obstáculos
│   ├── ashtray.tscn                 # Cenicero (hereda obstacle_base)
│   └── bottle.tscn                  # Frasco (hereda obstacle_base)
├── world/
│   ├── parallax_world.tscn          # ParallaxBackground con capas (fondo + frontal)
│   └── obstacle_spawner.tscn        # Nodo generador de obstáculos
└── effects/
    ├── rain_cloud.tscn              # Nube con sistema de partículas de lluvia
    └── wind_particles.tscn          # Partículas de viento

scripts/
├── autoloads/
│   └── game_manager.gd              # Singleton: estado global, señales globales
├── director/
│   └── director_controller.gd      # Teclas F1-F5, emite señales de eventos
├── player/
│   └── balloon_controller.gd       # Física: mechero, gravedad, movimiento lateral, knockback
├── obstacles/
│   ├── obstacle_base.gd            # Clase base: velocidad, dirección, knockback
│   └── obstacle_spawner.gd         # Spawn pool, cooldown, posición Y aleatoria
├── world/
│   └── parallax_manager.gd         # Gestión de capas, cambio de fondo (F1)
└── effects/
    ├── rain_cloud.gd               # Toggle lluvia, fuerza downward sobre globo
    └── wind_effect.gd              # Toggle viento, fuerza lateral sobre globo

assets/
├── sprites/                        # Sprites: globo, obstáculos (placeholders PNG)
├── backgrounds/                    # Fondos por capa (placeholders PNG)
├── audio/                          # Canción (placeholder — agregar manualmente)
└── shaders/
    └── vhs_effect.gdshader         # Shader VHS: scanlines, chromatic aberration, noise
```

**Structure Decision**: Single project. Todo dentro del repositorio Godot, sin sub-proyectos ni workspaces. Los assets de arte son placeholders reemplazables sin cambiar código.

---

## Phase 1: Setup

**Purpose**: Estructura base del proyecto lista para recibir código.

- [ ] T001 Crear estructura de carpetas (`scenes/`, `scripts/`, `assets/`, `specs/`) — ya completado
- [ ] T002 Registrar autoload `GameManager` en `project.godot` (`scripts/autoloads/game_manager.gd`)
- [ ] T003 Crear `scripts/autoloads/game_manager.gd` vacío con clase base y señales globales
- [ ] T004 Crear `scenes/main.tscn` con nodo raíz `Node2D` y referencias a sub-escenas

---

## Phase 2: Fundacional — Infraestructura base

**Purpose**: Sistemas core que deben estar listos antes de cualquier user story.

**⚠️ CRÍTICO**: Ninguna user story puede comenzar hasta completar esta fase.

- [ ] T005 Implementar `game_manager.gd` con señales: `event_director(event_name)`, `background_change()`, `wind_toggled(active)`, `rain_toggled(active)`, `birds_toggled(active)`
- [ ] T006 Crear `scripts/director/director_controller.gd`: escucha F1–F5, emite señales hacia GameManager
- [ ] T007 Crear `scenes/world/parallax_world.tscn` con `ParallaxBackground` y 4 `ParallaxLayer`: `sky_far` (z=-2), `clouds_mid` (z=-1), `elements_front` (z=1). El jugador vive en z=0, de modo que `elements_front` se renderiza por delante de él.
- [ ] T008 Crear `scripts/world/parallax_manager.gd`: controla velocidad de scroll, carga texturas desde `assets/backgrounds/`
- [ ] T009 Añadir `Camera2D` estática a `main.tscn` (fija, sin seguimiento)
- [ ] T010 Añadir `CanvasLayer` al final del árbol de `main.tscn` para el shader VHS
- [ ] T011 Crear `assets/shaders/vhs_effect.gdshader` con scanlines, chromatic aberration y noise estático

**Checkpoint**: El juego abre, muestra fondo con scroll, y el shader VHS es visible. Sin gameplay aún.

---

## Phase 3: User Story 1 — Control del globo aerostático (P1)

**Goal**: El jugador puede controlar el globo con física satisfactoria.

**Independent Test**: Ejecutar el juego (F5), verificar que el globo sube al presionar Espacio y baja al soltarlo, y que se mueve lateralmente sin salir de pantalla.

### Implementación para User Story 1

- [ ] T012 [US1] Crear `scenes/player/balloon.tscn` con la siguiente jerarquía:
  ```
  CharacterBody2D  (balloon_root)
  ├── Sprite2D          "balloon_sprite"   ← sprite del globo aerostático
  ├── Node2D            "skull_pivot"      ← punto de cuelgue (en el borde inferior del globo)
  │   └── Sprite2D      "skull_sprite"    ← calavera steampunk con parlante
  ├── CollisionShape2D                    ← cápsula que cubre globo + calavera
  └── CPUParticles2D    "burner_flame"    ← mechero (debajo del globo, arriba del skull_pivot)
  ```
  El `skull_pivot` se posiciona en el borde inferior del globo. La `skull_sprite` tiene un offset Y positivo (cuelga hacia abajo desde el pivot).

- [ ] T013 [US1] Crear `scripts/player/balloon_controller.gd` con:
  - Variables exportadas de física: `gravity`, `burner_force`, `lateral_speed`, `screen_margin`, `top_overflow`
  - Variables exportadas de inflado del globo:
    - `balloon_inflate_scale: float = 1.06` — escala máxima del sprite del globo cuando el quemador está activo (rango recomendado: 1.03–1.10)
    - `balloon_inflate_speed: float = 3.0` — velocidad de transición de inflado/desinflado (lerp factor)
  - **Lógica de inflado** en `_physics_process(delta)` — solo sobre `balloon_sprite`, nunca sobre el nodo raíz:
    ```
    var target_scale = balloon_inflate_scale if burner_active else 1.0
    var current = balloon_sprite.scale.x
    var new_scale = lerp(current, target_scale, balloon_inflate_speed * delta)
    balloon_sprite.scale = Vector2(new_scale, new_scale)
    ```
    El `CollisionShape2D` y la `skull_sprite` permanecen sin cambios.
  - Variables exportadas de comportamiento visual del cráneo:
    - `skull_sway_factor: float = 0.08` — qué tanto responde la calavera al movimiento lateral del globo (rango recomendado: 0.05–0.15)
    - `skull_sway_damping: float = 8.0` — velocidad con la que la calavera vuelve al centro (alto = más rígido, menos baile)
    - `skull_vertical_response: float = 0.04` — respuesta vertical de la calavera ante aceleración vertical del globo
  - `_physics_process(delta)`: aplicar gravedad, mechero (Input), movimiento lateral
  - Límites laterales e inferior: clamp duro
  - Límite superior: soft limit con `top_overflow`
  - **Lógica de sway de la calavera** (sin spring, solo lerp):
    ```
    var target_offset_x = -velocity.x * skull_sway_factor
    var target_offset_y = -velocity.y * skull_vertical_response
    skull_pivot.position = skull_pivot.position.lerp(
        Vector2(target_offset_x, skull_pivot.position.y + target_offset_y),
        skull_sway_damping * delta
    )
    ```
    El efecto es de "arrastre" puro: la calavera va en dirección opuesta al movimiento (lag) y vuelve al centro rápido. No oscila.
  - Señales `burner_activated` y `burner_deactivated` para efectos visuales

- [ ] T014 [US1] Conectar partículas del mechero a las señales `burner_activated/deactivated`
- [ ] T015 [US1] Añadir instancia de `balloon.tscn` a `main.tscn`
- [ ] T016 [US1] Implementar función `apply_knockback(direction: Vector2, force: float)` en `balloon_controller.gd`. El knockback afecta la velocidad del `CharacterBody2D` (el globo); la calavera lo seguirá automáticamente por el sistema de sway.

**Checkpoint**: El globo sube, baja, se mueve lateral, no sale de pantalla y tiene partículas de mechero.

---

## Phase 4: User Story 3 — Parallax y fondos (P2)

**Goal**: El fondo tiene profundidad visual y puede cambiarse con F1.

**Independent Test**: Ejecutar el juego y ver múltiples capas de fondo moviéndose a distintas velocidades. Presionar F1 para cambiar el fondo.

### Implementación para User Story 3

- [ ] T017 [US3] Completar `parallax_manager.gd`: array de texturas de fondo, índice actual, función `next_background()`
- [ ] T018 [US3] Implementar `next_background()` con `Tween` para cross-fade suave (1.5 segundos)
- [ ] T019 [US3] Conectar señal `background_change` de `GameManager` a `parallax_manager.next_background()`
- [ ] T020 [US3] Crear sprites placeholder de colores sólidos para los 3 fondos iniciales en `assets/backgrounds/` (se reemplazarán con arte final)
- [ ] T021 [US3] Configurar velocidades de scroll y z-index por capa: `sky_far` (scroll=0.2, z=-2), `clouds_mid` (scroll=0.5, z=-1), `elements_front` (scroll=1.2, z=1). El jugador tiene z=0 por defecto — `elements_front` queda visualmente delante de él.

**Checkpoint**: Fondo con parallax visible, F1 cambia el fondo con fade.

---

## Phase 5: User Story 2 — Obstáculos / recuerdos (P2)

**Goal**: Objetos cruzar la pantalla y empujan al globo al contacto.

**Independent Test**: Esperar spawn automático o presionar F5 para spawn manual, verificar colisión con knockback sin muerte.

### Implementación para User Story 2

- [ ] T022 [US2] Crear `scripts/obstacles/obstacle_base.gd`: variables `speed`, `direction` (±1), `knockback_force`; función `_process(delta)` para mover; auto-destrucción al salir de pantalla
- [ ] T023 [US2] Crear `scenes/obstacles/obstacle_base.tscn`: `Area2D` + `Sprite2D` (placeholder) + `CollisionShape2D`
- [ ] T024 [US2] Crear `scenes/obstacles/ashtray.tscn` heredando `obstacle_base.tscn`: dirección izq→der, sprite cenicero placeholder
- [ ] T025 [US2] Crear `scenes/obstacles/bottle.tscn` heredando `obstacle_base.tscn`: dirección der→izq, sprite frasco placeholder
- [ ] T026 [US2] Implementar detección de colisión en `obstacle_base.gd`: al detectar `balloon` en área, llamar `balloon.apply_knockback()` y emitir señal `hit_balloon`
- [ ] T027 [US2] Crear `scripts/obstacles/obstacle_spawner.gd`: timer de cooldown (configurable), posición Y aleatoria dentro de márgenes, alternancia aleatoria entre tipos de obstáculos
- [ ] T028 [US2] Crear `scenes/world/obstacle_spawner.tscn` con `Timer` y lógica de spawn
- [ ] T029 [US2] Añadir animación squish/stretch en `balloon_controller.gd` al recibir knockback (Tween sobre `scale`)
- [ ] T030 [US2] Conectar F5 del director al spawn manual de obstáculo

**Checkpoint**: Obstáculos aparecen, cruzan la pantalla y empujan el globo al contactar.

---

## Phase 6: User Story 4 — Sistema de Director (P3)

**Goal**: El operador puede controlar efectos visuales en tiempo real vía teclado.

**Independent Test**: Presionar F2, F3, F4 durante ejecución y verificar que cada efecto aparece, funciona y se puede desactivar.

### Implementación para User Story 4

- [ ] T031 [US4] Crear `scripts/effects/rain_cloud.gd`: toggle ON/OFF con `Tween` de aparición; en `_process(delta)` seguir la posición X del jugador con `lerp` lento (ej. factor 0.8–1.5) para un movimiento torpe con retraso; `CPUParticles2D` de lluvia; área de efecto que aplica fuerza downward al globo si está debajo
- [ ] T032 [US4] Crear `scenes/effects/rain_cloud.tscn`: `Node2D` + `Sprite2D` nube placeholder + `CPUParticles2D` lluvia + `Area2D` de efecto
- [ ] T033 [US4] Crear `scripts/effects/wind_effect.gd`: toggle ON/OFF, `CPUParticles2D` de viento, fuerza lateral aplicada al globo vía señal a `balloon_controller`
- [ ] T034 [US4] Crear `scenes/effects/wind_particles.tscn`: `CPUParticles2D` configurado para partículas de viento horizontal
- [ ] T035 [US4] Añadir capa de pájaros en `parallax_world.tscn`: `ParallaxLayer` con `AnimatedSprite2D` o instancias de sprites simples en movimiento; activable/desactivable
- [ ] T036 [US4] Conectar señales `rain_toggled`, `wind_toggled`, `birds_toggled` del GameManager a sus efectos correspondientes
- [ ] T037 [US4] Verificar que F2, F3, F4, F5 funcionan sin UI visible en pantalla

**Checkpoint**: Los 4 eventos del director funcionan con toggle correcto.

---

## Phase 7: User Story 5 — Audio (P3)

**Goal**: La canción suena durante el juego.

**Independent Test**: Colocar un archivo `.ogg` o `.mp3` en `assets/audio/`, ejecutar el juego, verificar que suena.

### Implementación para User Story 5

- [ ] T038 [US5] Añadir `AudioStreamPlayer` a `main.tscn` (o manejar desde `GameManager`)
- [ ] T039 [US5] En `game_manager.gd`: cargar audio desde `assets/audio/` si existe, reproducir al inicio con `play()`
- [ ] T040 [US5] Manejar el caso de audio inexistente sin crash (print warning y continuar)

**Checkpoint**: La canción suena al iniciar si hay archivo en assets/audio/.

---

## Phase N: Polish y Cross-Cutting

**Purpose**: Refinamientos que afectan a múltiples sistemas.

- [ ] T041 Ajustar shader VHS: intensidad configurable vía variable uniform, exportada para ajustar desde el inspector
- [ ] T042 Revisar feel del globo: ajustar `gravity`, `burner_force`, amortiguación lateral para sensación satisfactoria
- [ ] T043 Añadir comentarios de documentación en los scripts principales
- [ ] T044 Verificar que no hay errores en la consola de Godot durante 2 minutos de ejecución
- [ ] T045 Prueba de grabación completa: ejecutar el juego 2 minutos, triggerear todos los eventos del director, verificar fluidez

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: Sin dependencias — puede comenzar inmediatamente
- **Fundacional (Phase 2)**: Depende de Phase 1 — BLOQUEA todas las user stories
- **US1 — Globo (Phase 3)**: Depende de Phase 2
- **US3 — Parallax (Phase 4)**: Depende de Phase 2, independiente de US1
- **US2 — Obstáculos (Phase 5)**: Depende de US1 (necesita `apply_knockback`)
- **US4 — Director (Phase 6)**: Depende de Phase 2; los efectos de lluvia/viento se conectan al globo de US1
- **US5 — Audio (Phase 7)**: Depende de Phase 2 únicamente
- **Polish (Phase N)**: Depende de todas las fases anteriores

### Within Each Phase

- Scripts antes de escenas que los usan
- Clase base antes de clases derivadas
- Señales declaradas antes de conectarlas
- Placeholders de arte suficientes para probar sin assets finales

## Notes

- Los assets de arte (sprites, fondos) son placeholders. El código usa rutas en `assets/` — reemplazar el archivo PNG es suficiente para actualizar el arte sin tocar código.
- El número de fondos es extensible: agregar una textura al array en `parallax_manager.gd`.
- Nuevos tipos de obstáculos se crean heredando `obstacle_base.tscn` y `obstacle_base.gd`.
- Nuevos eventos del director se agregan en `director_controller.gd` con una nueva tecla y señal.
- Las variables de física del globo (`gravity`, `burner_force`, etc.) son `@export` — ajustables desde el inspector sin modificar código.
