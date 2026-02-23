# megalo-game — Contexto del proyecto

Juego desarrollado en **Godot 4** usando GDScript.
Proceso de desarrollo: **Specification-Driven Development (SDD)**.

---

## Workflow obligatorio para cualquier cambio

```
Bug fix pequeño       → implementar directo
Cambio de comportamiento  → /sdd-spec primero
Nueva feature         → /sdd-spec → /sdd-plan → /sdd-impl
Refactor estructural  → /sdd-plan (actualizar arquitectura) → implementar
```

**Nunca implementes algo que cambie la experiencia del jugador sin SPEC actualizado.**

---

## Comandos disponibles

| Comando | Cuándo usarlo |
|---------|--------------|
| `/sdd-spec` | Crear o actualizar la especificación de una feature |
| `/sdd-plan` | Crear o actualizar el plan de implementación |
| `/sdd-impl` | Implementar tareas del plan actual |

---

## Referencias de proceso

- `_sdd_docs/godot-conventions.md` — patrones y naming del proyecto
- `_sdd_docs/spec-template.md` — template para SPECs
- `_sdd_docs/plan-template.md` — template para PLANs

---

## Estado actual del proyecto

Ver `specs/` para el estado de cada feature documentada.

---

## Reglas importantes

1. Leer `_sdd_docs/godot-conventions.md` antes de escribir cualquier código
2. Cada script nuevo debe tener `class_name` si es reutilizable
3. Comunicación entre nodos: **señales**, no referencias directas
4. No hardcodear valores — usar `@export` para todo lo configurable
5. Marcar tareas como `- [x]` en el plan al completarlas
6. Si encontrás algo que contradice el SPEC, pausar y consultar
