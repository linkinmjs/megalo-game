# Convenciones de Godot — megalo-game

Este archivo documenta los patrones y convenciones aprobados para este proyecto.
Leelo antes de implementar cualquier feature.

---

## Estructura del proyecto

```
megalo-game/
├── scenes/              ← escenas .tscn organizadas por dominio
├── scripts/             ← scripts .gd (sin escena asociada: utils, resources, autoloads)
├── assets/              ← sprites, audio, fuentes
├── specs/               ← documentación SDD por feature
│   └── [feature]/
│       ├── spec.md
│       └── plan.md
├── _sdd_docs/           ← guías y templates de proceso
├── .claude/
│   └── commands/        ← slash commands de Claude Code
└── CLAUDE.md            ← contexto raíz del proyecto
```

---

## Naming conventions

| Artefacto | Convención | Ejemplo |
|-----------|-----------|---------|
| Escenas | PascalCase.tscn | `BalloonEnemy.tscn` |
| Scripts | snake_case.gd | `balloon_enemy.gd` |
| Clases (`class_name`) | PascalCase | `BalloonEnemy` |
| Nodos en escena | PascalCase | `AnimationPlayer`, `HurtBox` |
| Señales | snake_case pasado | `balloon_popped`, `player_died` |
| Variables públicas | snake_case | `max_speed` |
| Variables privadas | _snake_case | `_current_health` |
| Constantes | SCREAMING_SNAKE | `MAX_BALLOONS` |
| @export vars | snake_case | `float_speed` |

---

## Patrones preferidos

### Comunicación entre nodos: siempre señales

```gdscript
# ✅ Correcto
signal health_changed(new_value: int)
signal enemy_defeated(enemy: Node)

# ❌ Evitar: referencias directas con rutas
get_node("../../UI/HealthBar").update(health)
```

### Configuración desde Inspector: @export

```gdscript
# ✅ Correcto — configurable sin tocar código
@export var move_speed: float = 150.0
@export var damage: int = 1
@export var balloon_color: Color = Color.RED

# ❌ Evitar: valores hardcodeados en lógica
var speed = 150.0  # no configurable desde editor
```

### Estado de entidades: enum + match

```gdscript
enum State { IDLE, FLOATING, POPPING, DEAD }
var current_state: State = State.IDLE

func _physics_process(delta: float) -> void:
    match current_state:
        State.IDLE:
            _handle_idle(delta)
        State.FLOATING:
            _handle_floating(delta)
        State.POPPING:
            _handle_popping(delta)
```

### Datos compartidos: Resource

Cuando múltiples nodos necesitan los mismos datos (stats del jugador, config de
niveles, etc.), usar un `Resource` custom en lugar de variables globales.

```gdscript
# player_stats.gd
class_name PlayerStats
extends Resource

@export var max_health: int = 3
@export var lives: int = 3
@export var score: int = 0
```

### Autoloads: solo para sistemas verdaderamente globales

Usar Autoloads con moderación. Casos válidos:
- `EventBus` — para señales entre escenas no conectadas
- `AudioManager` — para sonidos globales
- `GameState` — para estado que persiste entre escenas

**No usar Autoload** para lógica de una sola escena.

---

## Tipos de nodos frecuentes en este proyecto

| Propósito | Nodo base sugerido |
|-----------|-------------------|
| Jugador con físicas | `CharacterBody2D` |
| Enemigo / objeto físico | `RigidBody2D` o `CharacterBody2D` |
| Hitbox / Hurtbox | `Area2D` + `CollisionShape2D` |
| Proyectil | `Area2D` o `CharacterBody2D` |
| UI elemento | `Control` (o subclase) |
| Partículas | `GPUParticles2D` |
| Audio | `AudioStreamPlayer2D` (posicional) o `AudioStreamPlayer` (global) |

---

## Testing manual en Godot

Formato estándar para describir un test en el PLAN:

```
Test: Abrir [NombreEscena.tscn] → [acción: presionar X / mover hacia Y] 
      → verificar [resultado observable en pantalla o en Remote Debugger]
```

Para debug rápido, agregar temporalmente:
```gdscript
print("[NombreClase] estado: ", current_state, " | pos: ", global_position)
```

Eliminar prints antes de marcar la tarea como ✅.
