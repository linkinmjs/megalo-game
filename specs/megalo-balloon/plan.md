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
├── main.tscn                        # Escena raíz del juego (gameplay)
├── menus/
│   ├── main_menu.tscn               # Pantalla de inicio: título, Play, Settings
│   ├── settings_menu.tscn           # Sliders de volumen Música y SFX
│   └── pause_menu.tscn              # Overlay de pausa: Reanudar, Settings, Salir
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
│   └── game_manager.gd              # Singleton: estado global, señales globales, gestión de escenas
├── director/
│   └── director_controller.gd      # Teclas F1-F5, emite señales de eventos
├── menus/
│   ├── main_menu.gd                 # Lógica de botones, ambient audio del menú
│   ├── settings_menu.gd             # Bind sliders → AudioServer buses, persistencia con ConfigFile
│   └── pause_controller.gd         # Escape toggle, fade out/in de música, get_tree().paused
├── player/
│   └── balloon_controller.gd       # Física: mechero, gravedad, movimiento lateral, knockback, sway
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
├── backgrounds/                    # Fondos por capa organizados en sets
├── audio/                          # Canción (placeholder — agregar manualmente)
├── locale/
│   └── translations.csv            # Traducciones EN/ES/PT en formato CSV de Godot
└── shaders/
    └── vhs_effect.gdshader         # Shader VHS (implementado, desactivado hasta polish)
```

**Structure Decision**: Single project. Todo dentro del repositorio Godot, sin sub-proyectos ni workspaces. Los assets de arte son placeholders reemplazables sin cambiar código.

---

## Phase 1: Setup ✅

**Purpose**: Estructura base del proyecto lista para recibir código.

- [x] T001 Crear estructura de carpetas (`scenes/`, `scripts/`, `assets/`, `specs/`)
- [x] T002 Registrar autoload `GameManager` en `project.godot`
- [x] T003 Crear `scripts/autoloads/game_manager.gd` con señales globales y transición de escenas
- [x] T004 Crear `scenes/main.tscn` con nodo raíz `Node2D` y referencias a sub-escenas

---

## Phase 2: Fundacional — Infraestructura base ✅

**Purpose**: Sistemas core que deben estar listos antes de cualquier user story.

- [x] T005 `game_manager.gd` con señales: `event_director`, `background_change`, `wind_toggled`, `rain_toggled`, `birds_toggled`
- [x] T006 `scripts/director/director_controller.gd`: escucha F1–F5, emite señales hacia GameManager
- [x] T007 `scenes/world/parallax_world.tscn` con `ParallaxBackground` y capas `SkyFar`, `CloudsMid`, `ElementsFront`
- [x] T008 `scripts/world/parallax_manager.gd`: scroll automático con `scroll_base_offset`
- [x] T009 `Camera2D` estática en `main.tscn`
- [x] T010 Overlay de transición (fade a negro) en `GameManager`
- [x] T011 `assets/shaders/vhs_effect.gdshader` implementado *(desactivado — ver TODO en game_manager.gd)*
- [x] T011b `default_bus_layout.tres` con buses `Master`, `Music` y `SFX`

**Checkpoint**: ✅ Infraestructura lista. Shader VHS implementado pero desactivado durante desarrollo.

---

## Phase 3: Sistema de Menús (US6, US7, US8) ✅

**Purpose**: El juego debe verse como un juego real. Menú de inicio, configuración y pausa.

### Implementación de Menús

- [x] T012m `scenes/menus/main_menu.tscn` + `scripts/menus/main_menu.gd`: título, Play, Settings, ambient audio
- [x] T013m `scenes/menus/settings_menu.tscn` + `scripts/menus/settings_menu.gd`: sliders Music/SFX, persistencia ConfigFile, botón Volver
- [x] T014m `scenes/menus/pause_menu.tscn` + `scripts/menus/pause_controller.gd`: Escape toggle, fade out/in de música, settings embebido en panel secundario, botón Salir al menú
- [x] T015m `scripts/world/main_scene.gd`: registra MusicPlayer en GameManager al cargar la escena de juego
- [x] T016m `project.godot`: escena principal = `main_menu.tscn`, autoload `GameManager`

**Checkpoint**: ✅ Flujo completo menú → juego → pausa funcionando. Pendiente: selector de idioma (Phase 9).

- [ ] T012m [US6] Crear `scenes/menus/main_menu.tscn`:
  - Nodo raíz `Control` (pantalla completa)
  - `Label` con el nombre del juego
  - `Button` "Play" y `Button` "Settings"
  - `AudioStreamPlayer` para el sonido de ambientación del menú (bus: SFX)

- [ ] T013m [US6] Crear `scripts/menus/main_menu.gd`:
  - Al entrar a la escena: reproducir ambient audio en loop
  - Botón Play → `GameManager.change_scene("main")` con fade a negro
  - Botón Settings → `GameManager.change_scene("settings_menu")` pasando "main_menu" como escena de retorno

- [ ] T014m [US7] Crear `scenes/menus/settings_menu.tscn`:
  - `HSlider` para "Música" (bus Music) y `HSlider` para "SFX" (bus SFX)
  - `Button` "Volver"

- [ ] T015m [US7] Crear `scripts/menus/settings_menu.gd`:
  - Bind de cada slider a `AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))`
  - Al entrar: leer valores actuales de los buses y setear posición inicial de sliders
  - Persistencia: guardar/cargar volúmenes con `ConfigFile` en `user://settings.cfg`
  - Botón Volver → regresar a escena de origen (main_menu o pause_menu)

- [ ] T016m [US8] Crear `scenes/menus/pause_menu.tscn`:
  - `CanvasLayer` (para renderizar sobre el gameplay)
  - Panel semi-transparente de fondo
  - `Button` "Reanudar", `Button` "Configuración", `Button` "Salir al menú"

- [ ] T017m [US8] Crear `scripts/menus/pause_controller.gd`:
  - Escuchar `ui_cancel` (Escape) en `_unhandled_input`
  - **Pausar**: crear `Tween` que lleva `music_player.volume_db` de 0 a -80 en 1.0s, luego `stream_paused = true` y `get_tree().paused = true`
  - **Reanudar**: `stream_paused = false`, crear `Tween` que lleva `volume_db` de -80 a 0 en 0.5s, `get_tree().paused = false`
  - El nodo `pause_controller` debe tener `process_mode = PROCESS_MODE_ALWAYS` para seguir procesando mientras el árbol está pausado
  - Botón Salir → `get_tree().paused = false`, fade a negro, cargar main_menu

- [ ] T018m Agregar `GameManager.change_scene(scene_name)` como función utilitaria: fade out a negro (`CanvasLayer` + `ColorRect` + `Tween`), cambiar escena, fade in

**Checkpoint**: El juego arranca en el menú de inicio, Play inicia el juego, Settings ajusta el volumen, Escape pausa con fade de música y reanuda correctamente.

---

## Phase 4: User Story 1 — Control del globo aerostático (P1) ✅

**Goal**: El jugador puede controlar el globo con física satisfactoria.

**Independent Test**: Ejecutar el juego (F5), verificar que el globo sube al presionar Espacio y baja al soltarlo, y que se mueve lateralmente sin salir de pantalla.

### Implementación para User Story 1

- [x] T012 [US1] Crear `scenes/player/balloon.tscn` con la siguiente jerarquía:
  ```
  CharacterBody2D  (balloon_root)
  ├── Sprite2D          "balloon_sprite"   ← sprite del globo aerostático
  ├── Node2D            "skull_pivot"      ← punto de cuelgue (en el borde inferior del globo)
  │   └── Sprite2D      "skull_sprite"    ← calavera steampunk con parlante
  ├── CollisionShape2D                    ← cápsula que cubre globo + calavera
  └── CPUParticles2D    "burner_flame"    ← mechero (debajo del globo, arriba del skull_pivot)
  ```
  El `skull_pivot` se posiciona en el borde inferior del globo. La `skull_sprite` tiene un offset Y positivo (cuelga hacia abajo desde el pivot).

- [x] T013 [US1] Crear `scripts/player/balloon_controller.gd` con:
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

- [x] T014 [US1] Partículas del mechero controladas directamente por `_burner_active` en el script (sin señales separadas — simplificación válida)
- [x] T015 [US1] Instancia de `balloon.tscn` añadida a `main.tscn` dentro de `GameWorld`
- [x] T016 [US1] `apply_knockback(direction, force)` implementado con squish/stretch en `VisualRoot`

**Checkpoint**: El globo sube, baja, se mueve lateral, no sale de pantalla y tiene partículas de mechero.

---

## Phase 5: User Story 3 — Parallax y fondos (P2) ✅

**Goal**: El fondo tiene profundidad visual y puede cambiarse con F1.

**Independent Test**: Ejecutar el juego y ver múltiples capas de fondo moviéndose a distintas velocidades. Presionar F1 para cambiar el fondo.

### Implementación para User Story 3

- [x] T017 [US3] Completar `parallax_manager.gd`: array de texturas de fondo, índice actual, función `next_background()`
- [x] T018 [US3] Implementar `next_background()` con `Tween` para cross-fade suave (1.5 segundos)
- [x] T019 [US3] Conectar señal `background_change` de `GameManager` a `parallax_manager.next_background()`
- [x] T020 [US3] Assets de fondos reales disponibles en `assets/backgrounds/` (sky_clouds, post_apocalypse, nature, city_ruins). Se usan 3 sets: sky_clouds/set_01, sky_clouds/set_03, post_apocalypse/set_01.
- [x] T021 [US3] Configurar velocidades de scroll y z-index por capa: `sky_far` (scroll=0.2, z=-2), `clouds_mid` (scroll=0.5, z=-1), `elements_front` (scroll=1.2, z=1). El jugador tiene z=0 por defecto — `elements_front` queda visualmente delante de él.

**Checkpoint**: Fondo con parallax visible, F1 cambia el fondo con fade.

> ✅ **BUG RESUELTO (2026-02-22):** Las texturas eran 576×324px (45% del viewport 1280×720).
> Sin escalado, los sprites cubrían solo el 45% superior de la pantalla.
> **Fix:** en `_load_background()` se escala cada sprite por `vp_h / tex_h` (~2.22×) y se
> actualiza `motion_mirroring` al ancho escalado (`tex_w * scale_factor = 1280px`) para
> que las copias del tiling se posicionen sin costura.

> ⚠️ **NOTA (2026-02-22):** Las tareas T007 y T021 serán parcialmente reemplazadas por
> Phase 5b. T007 creó las capas hardcodeadas en la escena (SkyFar/CloudsMid/ElementsFront);
> Phase 5b las moverá a código dinámico. T021 configuró scroll/z-index en la escena;
> Phase 5b los pasa a `LAYER_CONFIGS`.

---

## Phase 5b: Parallax — N capas con soporte frontal (US3 — FR-036 a FR-040)

**Goal**: Refactorizar el parallax para soportar cualquier número de capas configurables por set. Las capas con `z_index > 0` se renderizan delante del player (vegetación, niebla), creando inmersión visual.

**Prerequisite**: Phase 5 completada (✅)

**Independent Test**: Ejecutar el juego con un set que incluya textura en el slot frontal → verificar que elementos aparecen delante del globo. Presionar F1 → verificar que todas las capas (incluyendo la frontal) transicionan juntas.

### Diseño técnico

**Árbol de nodos (post-refactor):**
```
ParallaxWorld (Node2D)  ← parallax_manager.gd
└── ParallaxBackground
    ├── ParallaxLayer_0   ← creado dinámicamente, z=-2, scroll_x=0.2  (fondo lejano)
    ├── ParallaxLayer_1   ← creado dinámicamente, z=-1, scroll_x=0.5  (fondo medio)
    ├── ParallaxLayer_2   ← creado dinámicamente, z=0,  scroll_x=1.0  (fondo cercano)
    └── ParallaxLayer_N   ← creado dinámicamente, z=2,  scroll_x=1.5  (frontal, delante player)
```

**Cambio de datos en `parallax_manager.gd`:**
```
# Antes (3 claves fijas):
BACKGROUND_SETS = [{"far": path, "mid": path, "front": path}]

# Después (N slots por índice):
LAYER_CONFIGS = [{"scroll_x": 0.2, "z_index": -2}, ...]   ← nuevo, slots globales
BACKGROUND_SETS = [{"textures": [path0, path1, ..., ""]}]  ← índice = slot de LAYER_CONFIGS
```

**Señales:** sin cambios. `background_change` → `next_background()` sigue igual.

**@exports:** sin cambios. `scroll_speed` y `fade_duration` no se modifican.

### Implementación

- [x] T056 [US3] Agregar constante `LAYER_CONFIGS` en `parallax_manager.gd`: `Array` de dicts `{"scroll_x": float, "z_index": int}`, uno por slot de capa; sustituye a la config hardcodeada de SkyFar/CloudsMid/ElementsFront → `scripts/world/parallax_manager.gd`
- [x] T057 [US3] Reemplazar refs `@onready` (`sky_far`, `clouds_mid`, `elements_front`) por función `_create_layers()` que instancia un `ParallaxLayer` por cada entrada de `LAYER_CONFIGS`, configura `motion_scale` y `z_index`, y lo agrega como hijo de `parallax_bg` → `scripts/world/parallax_manager.gd`
- [x] T058 [US3] Refactorizar formato de `BACKGROUND_SETS`: cambiar de dict con claves fijas `{"far", "mid", "front"}` a dict `{"textures": Array[String]}` donde el índice del array mapea al slot correspondiente en `LAYER_CONFIGS` → `scripts/world/parallax_manager.gd`
- [x] T059 [US3] Actualizar `_load_background()`: iterar sobre `LAYER_CONFIGS.size()` slots; si el set no define textura para ese slot (array más corto o string vacío `""`) → poner sprite invisible (`modulate.a = 0`, `texture = null`); si define textura → cargar con la misma lógica de escala existente → `scripts/world/parallax_manager.gd`
- [x] T060 [US3] Eliminar nodos hijos hardcodeados (`SkyFar`, `CloudsMid`, `ElementsFront`) del `ParallaxBackground` en `parallax_world.tscn`; dejar el nodo vacío (los hijos los crea el script en `_ready()`) → `scenes/world/parallax_world.tscn`
- [x] T061 [US3] Actualizar los datos de `BACKGROUND_SETS` al nuevo formato `{"textures": [...]}` con los paths reales existentes; añadir al menos un set que incluya una textura en el slot frontal (z > 0) para validar la feature visualmente → `scripts/world/parallax_manager.gd`

**Checkpoint**: ✅ Abrir `main.tscn` → F5 → verificar que el fondo tiene múltiples capas con distintas velocidades. Usar un set con capa frontal → verificar que elementos semi-transparentes aparecen delante del globo. Presionar F1 → verificar que todas las capas transicionan suavemente.

> ✅ **Implementado (2026-02-23):** 4 slots dinámicos (z: -2, -1, 0, +2). sky_clouds/set_01 y set_03 usan las 4 capas incluyendo la frontal (delante del globo). post_apocalypse/set_01 usa 3 capas (sin frontal). Nodos hardcodeados eliminados de parallax_world.tscn.

---

## Phase 6: User Story 2 — Obstáculos / recuerdos (P2)

**Goal**: Objetos cruzar la pantalla y empujan al globo al contacto.

**Independent Test**: Esperar spawn automático o presionar F5 para spawn manual, verificar colisión con knockback sin muerte.

### Implementación para User Story 2

- [x] T022 [US2] Crear `scripts/obstacles/obstacle_base.gd`: variables `speed`, `direction` (±1), `knockback_force`; función `_process(delta)` para mover; auto-destrucción al salir de pantalla
- [x] T023 [US2] Crear `scenes/obstacles/obstacle_base.tscn`: `Area2D` + `Polygon2D` (placeholder visible sin textura) + `CollisionShape2D`
- [x] T024 [US2] Crear `scenes/obstacles/ashtray.tscn` heredando `obstacle_base.tscn`: dirección izq→der, color naranja
- [x] T025 [US2] Crear `scenes/obstacles/bottle.tscn` heredando `obstacle_base.tscn`: dirección der→izq, color azul
- [x] T026 [US2] Implementar detección de colisión en `obstacle_base.gd`: al detectar `balloon` en área, llamar `balloon.apply_knockback()` y emitir señal `hit_balloon`
- [x] T027 [US2] Crear `scripts/obstacles/obstacle_spawner.gd`: timer de cooldown (configurable), posición Y aleatoria dentro de márgenes, alternancia aleatoria entre tipos de obstáculos
- [x] T028 [US2] Crear `scenes/world/obstacle_spawner.tscn` con `Timer` y lógica de spawn
- [x] T029 [US2] Animación squish/stretch ya implementada en `balloon_controller.gd` (apply_knockback → _play_squish, Tween sobre VisualRoot.scale)
- [x] T030 [US2] ~~F5 del director emite `event_director("spawn_obstacle")`~~ → **reemplazado por director-obstacle-intensity** (escalones de frecuencia con double-tap reset)

**Checkpoint**: Obstáculos aparecen, cruzan la pantalla y empujan el globo al contactar.

---

## Phase 7: User Story 4 — Sistema de Director (P3)

**Goal**: El operador puede controlar efectos visuales en tiempo real vía teclado.

**Independent Test**: Presionar F2, F3, F4 durante ejecución y verificar que cada efecto aparece, funciona y se puede desactivar.

### Implementación para User Story 4

- [x] T031 [US4] Crear `scripts/effects/rain_cloud.gd`: toggle ON/OFF con `Tween`; sigue al player con lerp (follow_speed=1.2); `CPUParticles2D` de lluvia; `Area2D` que emite señal de fuerza downward al globo
- [x] T032 [US4] Crear `scenes/effects/rain_cloud.tscn`: `Node2D` + `Polygon2D` nube placeholder + `CPUParticles2D` lluvia + `Area2D` de efecto (RectangleShape2D 250×300 a y+150)
- [x] T033 [US4] Crear `scripts/effects/wind_effect.gd`: toggle ON/OFF, `CPUParticles2D` de viento, señal `wind_force_changed(force)` al balloon_controller
- [x] T034 [US4] Crear `scenes/effects/wind_particles.tscn`: `CPUParticles2D` horizontal screen-wide (emission_box, local_coords=false)
- [x] T035 [US4] Capa de pájaros añadida a `parallax_manager.gd`: `toggle_birds()` crea/destruye `ParallaxLayer` dinámico (motion_scale=2.5, z=1, mirror=1280); 8 siluetas Polygon2D placeholder; conexión a `GameManager.birds_toggled`
- [x] T036 [US4] Señales cableadas: rain/wind/birds → efectos en sus `_ready()` via GameManager; fuerzas → balloon via `main_scene.gd` (`rain_force_changed → receive_rain_force`, `wind_force_changed → receive_wind_force`)
- [x] T037 [US4] Verificación: ningún efecto agrega UI visible; todos los toggles F2-F5 son invisibles al stream

**Checkpoint**: Los 4 eventos del director funcionan con toggle correcto.

---

## Phase 8: User Story 5 — Audio (P3)

**Goal**: La canción suena durante el juego.

**Independent Test**: Colocar un archivo `.ogg` o `.mp3` en `assets/audio/`, ejecutar el juego, verificar que suena.

### Implementación para User Story 5

- [x] T038 [US5] Añadir `AudioStreamPlayer` a `main.tscn` (ya existía — bus: Music)
- [x] T039 [US5] En `main_scene.gd`: escanear `assets/audio/` con `DirAccess`, cargar el primer `.mp3`/`.ogg` encontrado, asignar stream y reproducir con loop
- [x] T040 [US5] Manejar el caso de audio inexistente sin crash (`push_warning` y continuar)

**Checkpoint**: La canción suena al iniciar si hay archivo en assets/audio/.

---

## Phase 9: User Story 9 — Localización (US9)

**Goal**: Soporte de tres idiomas (ES/EN/PT) con selección en Settings y persistencia.

**Independent Test**: Cambiar idioma en Settings → verificar que todos los textos de menús cambian. Cerrar y reabrir → verificar que el idioma persiste.

### Implementación para User Story 9

- [ ] T046 [US9] Crear `assets/locale/translations.csv` con todas las claves de UI:

  | key | es | en | pt |
  |-----|----|----|-----|
  | `MENU_PLAY` | Jugar | Play | Jogar |
  | `MENU_SETTINGS` | Configuración | Settings | Configurações |
  | `SETTINGS_TITLE` | Configuración | Settings | Configurações |
  | `SETTINGS_MUSIC` | Música | Music | Música |
  | `SETTINGS_SFX` | SFX | SFX | SFX |
  | `SETTINGS_LANGUAGE` | Idioma | Language | Idioma |
  | `SETTINGS_BACK` | Volver | Back | Voltar |
  | `PAUSE_TITLE` | Pausado | Paused | Pausado |
  | `PAUSE_RESUME` | Reanudar | Resume | Retomar |
  | `PAUSE_SETTINGS` | Configuración | Settings | Configurações |
  | `PAUSE_QUIT` | Salir al menú | Back to Menu | Sair ao menu |

- [ ] T047 [US9] Importar `translations.csv` en Godot: `Project Settings > Localization > Translations > Add` → Godot genera `.translation` binarios automáticamente

- [ ] T048 [US9] Actualizar todos los nodos `Label` y `Button` en las tres escenas de menú para usar claves de traducción (ej. `text = "MENU_PLAY"`). Godot auto-traduce si `auto_translate_mode = AUTO_TRANSLATE_MODE_ALWAYS` (default)

- [ ] T049 [US9] Añadir `OptionButton` "Idioma / Language" a `settings_menu.tscn` y al panel embebido en `pause_menu.tscn` con opciones ordenadas: `Español`, `English`, `Português`

- [ ] T050 [US9] Actualizar `settings_menu.gd` y `pause_controller.gd`:
  ```gdscript
  const LOCALES := ["es", "en", "pt"]

  func _on_language_changed(index: int) -> void:
      TranslationServer.set_locale(LOCALES[index])
      _save_settings()  # guarda locale junto con volúmenes
  ```

- [ ] T051 [US9] Cargar idioma guardado en `GameManager._ready()` antes de que cargue la primera escena:
  ```gdscript
  var cfg := ConfigFile.new()
  if cfg.load("user://settings.cfg") == OK:
      TranslationServer.set_locale(cfg.get_value("locale", "language", "es"))
  ```

**Checkpoint**: Cambiar idioma en Settings actualiza toda la UI en tiempo real. El idioma persiste al cerrar y reabrir el juego.

---

## Phase A: Nueva animación de golpe / hurt (specs/hurt-animation/spec.md)

**Goal**: Reemplazar squish/stretch por flash de color rojo + freeze de input + impulso moderado.

**Independent Test**: Un obstáculo golpea al globo → se pone rojo ~0.4s, no responde al input ~0.3s, no cambia de tamaño.

- [x] T-HURT-001 `scripts/player/balloon_controller.gd`: agregar `_hit_active: bool = false`; eliminar `_squish_tween: Tween`
- [x] T-HURT-002 `scripts/player/balloon_controller.gd`: en `_handle_input()`, agregar al inicio — si `_hit_active`: aplicar solo gravedad y `return`
- [x] T-HURT-003 `scripts/player/balloon_controller.gd`: agregar `_play_hit_effect()` — flash rojo en `visual_root.modulate` + fade a blanco en 0.4s + timer de 0.3s que desactiva `_hit_active`
- [x] T-HURT-004 `scripts/player/balloon_controller.gd`: actualizar `apply_knockback()` — reemplazar llamada `_play_squish()` por `_play_hit_effect()`
- [x] T-HURT-005 `scripts/player/balloon_controller.gd`: eliminar función `_play_squish()` completa

**Checkpoint**: Colisión con obstáculo → globo rojo → fade a blanco; sin cambio de escala; input bloqueado ~0.3s.

---

## Phase B: Aspiradora — reemplaza efecto de viento F3 (specs/aspiradora/spec.md)

**Goal**: Reemplazar WindEffect por VacuumEffect: aspiradora que asoma desde la izquierda y succiona al globo.

**Independent Test**: F3 → aspiradora entra desde borde izquierdo, globo deriva hacia la izquierda, partículas van hacia la izquierda. F3 → sale todo.

- [x] T-ASP-001 `scripts/effects/vacuum_effect.gd`: clase VacuumEffect — toggle ON/OFF via `wind_toggled`, Tween de posición (entrada/salida desde borde izq), emite `suction_force_changed` con valor negativo (atracción)
- [x] T-ASP-002 `scenes/effects/vacuum_effect.tscn`: Node2D + Polygon2D placeholder (cuerpo aspiradora) + CPUParticles2D (partículas que van hacia la izquierda, `direction=(-1,0)`)
- [x] T-ASP-003 `scenes/main.tscn`: reemplazar instancia `WindEffect` (wind_particles.tscn) por `VacuumEffect` (vacuum_effect.tscn)
- [x] T-ASP-004 `scripts/world/main_scene.gd`: cambiar `@onready wind_effect` → `vacuum_effect`; reconectar `suction_force_changed` → `balloon.receive_wind_force`
- [x] T-ASP-005 Eliminar `scenes/effects/wind_particles.tscn` y `scripts/effects/wind_effect.gd` (deprecated)

**Checkpoint**: F3 activa aspiradora con visual + succión hacia la izquierda + partículas. F3 desactiva todo.

---

## Phase C: Pájaros marioneta — animación entrada/salida F4 (specs/pajaros-marioneta/spec.md)

**Goal**: Reemplazar aparición instantánea de pájaros por descenso/ascenso animado con hilo visible por encima de cada pájaro.

**Independent Test**: F4 → pájaros bajan desde arriba con animación suave, hilo visible encima de cada uno, se desplazan horizontalmente. F4 → suben y desaparecen.

- [x] T-BIRD-001 `scripts/effects/birds_controller.gd`: clase BirdsController — toggle via `birds_toggled`, Tween de descenso/ascenso del contenedor de pájaros, `_process` para scroll horizontal con wraparound, `_make_bird_marionette()` que crea Polygon2D (silueta) + Line2D (hilo de 700px hacia arriba)
- [x] T-BIRD-002 `scenes/effects/birds_controller.tscn`: Node2D raíz con script (sin hijos — se crean dinámicamente)
- [x] T-BIRD-003 `scenes/main.tscn`: añadir instancia `BirdsController` en `GameWorld`
- [x] T-BIRD-004 `scripts/world/parallax_manager.gd`: eliminar `_bird_layer`, `toggle_birds()`, `_create_bird_layer()`, `_make_bird_shape()` y la conexión `birds_toggled` en `_ready()`

**Checkpoint**: F4 → pájaros descienden animados con hilos. F4 → ascienden. Sin rastros de la lógica anterior en parallax_manager.

---

## Phase N: Polish y Cross-Cutting

**Purpose**: Refinamientos que afectan a múltiples sistemas.

- [x] T052 Reactivar shader VHS en `game_manager.gd` + uniforms exportados (`vhs_scanline_strength`, `vhs_chromatic_aberration`, `vhs_noise_strength`) ajustables desde Inspector
- [ ] T053 Revisar feel del globo: ajustar `gravity`, `burner_force`, amortiguación lateral para sensación satisfactoria — **manual, en Inspector del nodo Balloon**
- [ ] T054 Verificar que no hay errores en la consola de Godot durante 2 minutos de ejecución — **manual**
- [ ] T055 Prueba de grabación completa: ejecutar el juego 2 minutos, triggerear todos los eventos del director, verificar fluidez — **manual**

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: Sin dependencias ✅
- **Fundacional (Phase 2)**: Depende de Phase 1 ✅
- **Menús (Phase 3)**: Depende de Phase 2 ✅
- **US1 — Globo (Phase 4)**: Depende de Phase 2
- **US3 — Parallax (Phase 5)**: Depende de Phase 2, independiente de US1
- **US2 — Obstáculos (Phase 6)**: Depende de US1 (necesita `apply_knockback`)
- **US4 — Director (Phase 7)**: Depende de Phase 2; los efectos de lluvia/viento se conectan al globo de US1
- **US5 — Audio (Phase 8)**: Depende de Phase 2; el fade de pausa usa el AudioStreamPlayer de esta fase
- **Localización (Phase 9)**: Depende de Phase 3 (escenas de menú deben existir); independiente del gameplay
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
