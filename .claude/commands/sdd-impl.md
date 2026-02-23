# /sdd-impl — Implementar tareas del PLAN

Cuando el usuario invoca este comando, sigue este proceso exacto.

## Tu rol

Sos el developer. Tu trabajo es implementar exactamente lo que dice el PLAN,
sin inventar arquitectura nueva ni desviarte del SPEC.

## Paso 1: Cargar contexto

Lee en este orden:
1. `CLAUDE.md`
2. `_sdd_docs/godot-conventions.md`
3. `specs/[feature]/spec.md`
4. `specs/[feature]/plan.md` — identificá las tareas pendientes `- [ ]`
5. Archivos existentes que vas a modificar (leer antes de tocar)

Si el usuario no especificó qué tarea, preguntale o sugerí la primera `- [ ]` del plan.

## Paso 2: Implementar

Para cada tarea:

1. **Anuncia** qué vas a hacer: `Implementando T### — [descripción]`
2. **Escribe el código** siguiendo las convenciones de `_sdd_docs/godot-conventions.md`
3. **Marca la tarea** como completada en el plan: cambiá `- [ ]` por `- [x]`
4. **Indicá el test**: cómo verificar que funciona

### Convenciones de código GDScript obligatorias

```gdscript
class_name NombreClase   # siempre si es reutilizable
extends TipoNodo

## Descripción breve del nodo (doc comment)

signal nombre_evento(param: Tipo)   # señales arriba

@export var velocidad: float = 200.0   # exports configurables

var _variable_privada: Tipo   # variables con _ si son privadas

func _ready() -> void:
    pass

func _physics_process(delta: float) -> void:
    pass

func nombre_publico() -> TipoRetorno:
    pass

func _nombre_privado() -> void:   # privados con _
    pass
```

**Regla de señales**: Siempre preferir señales sobre referencias directas entre nodos.
No uses `get_node()` con rutas hardcodeadas. Usá `@onready` o `@export`.

## Paso 3: Checkpoint

Después de cada User Story completa (todas sus tareas en ✅), indicá:

```
✅ User Story [N] completa

Test: Abrí [nombre_escena.tscn] → [acción concreta] → deberías ver [resultado]

Tareas completadas: T### T### T###
Próxima tarea: T### — [descripción]
¿Continuar con la siguiente tarea? (o podés testear primero)
```

## Paso 4: Si encontrás algo inesperado

Si durante la implementación descubrís que:
- El SPEC es ambiguo → **pausá** y preguntá antes de asumir
- El PLAN tiene una tarea imposible o incorrecta → **notificá** al usuario y sugerí
  correr `/sdd-plan` para actualizar antes de continuar
- La arquitectura existente no encaja con lo planeado → **explicá** el conflicto
  con opciones, no implementes por tu cuenta

Nunca implementes algo que contradiga el SPEC sin confirmación explícita.
