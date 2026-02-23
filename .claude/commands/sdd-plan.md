# /sdd-plan — Crear o actualizar un PLAN de implementación

Cuando el usuario invoca este comando, sigue este proceso exacto.

## Tu rol

Sos el arquitecto técnico del juego. Tu trabajo es traducir los SPEC en tareas
concretas y ordenadas que pueden ejecutarse en Godot 4.

## Paso 1: Leer el contexto completo

Lee en este orden:
1. `CLAUDE.md` — convenciones del proyecto
2. `_sdd_docs/godot-conventions.md` — patrones de Godot aprobados para este proyecto
3. `specs/[feature]/spec.md` — el SPEC que vas a planificar
4. Si existe, `specs/[feature]/plan.md` — el plan actual (para actualización)
5. Scripts y escenas relevantes existentes en `scripts/` y `scenes/` — para no duplicar

## Paso 2: Para actualizaciones, identificar el delta

Si ya existe un `plan.md`, identificá claramente:
- ¿Qué tareas se completan (✅)?
- ¿Qué tareas existentes cambian por el nuevo SPEC?
- ¿Qué tareas nuevas se agregan?
- ¿Cambia alguna prioridad?

Nunca borres tareas completadas (✅). Solo agregás, modificás pendientes, o marcás
como `[OBSOLETO]` las que ya no aplican.

## Paso 3: Diseño técnico

Antes de listar tareas, definí:

**Árbol de nodos nuevos o modificados:**
```
[NombreEscena] ([Tipo]) ← script.gd
├── [Hijo] ([Tipo])
└── ...
```

**Señales involucradas:**
| Señal | Definida en | Escuchada por |
|-------|------------|--------------|

**@exports configurables:**
| Variable | Tipo | Nodo | Para qué |
|----------|------|------|----------|

**¿Nuevo Autoload necesario?** (solo si es un sistema global)

## Paso 4: Escribir las tareas

Usa la estructura de `_sdd_docs/plan-template.md`.

Reglas para las tareas:
- Cada tarea = un archivo concreto (`.gd` o `.tscn`) o una acción verificable
- Formato: `- [ ] T### [P?] [US#] Descripción → archivo/destino`
  - `[P]` = prioritario/bloqueante
  - `[US1]` = a qué User Story del SPEC corresponde
- Primero Resources, luego scripts, luego escenas, luego señales, luego feedback
- Cada User Story tiene su propio checkpoint de testing con instrucción concreta:
  `Abrir [escena] → hacer [acción] → verificar [resultado]`

**Prioridades de fases:**
- P1 = sin esto no hay MVP jugable
- P2 = mejora significativa de la experiencia
- P3 = polish, audio, efectos visuales

## Paso 5: Guardar y notificar

Guardá en: `specs/[feature]/plan.md`

Luego indicá:
```
✅ PLAN guardado en specs/[feature]/plan.md

Resumen:
- X tareas nuevas agregadas
- Y tareas modificadas  
- Próxima tarea sugerida: T### — [descripción]

Para implementar: referenciá este plan y el spec en tu próximo chat
```
