# Feature Specification: Director — Control de Intensidad de Obstáculos

**Created**: 2026-02-23
**Reemplaza**: `specs/megalo-balloon/spec.md` → US4 Scenario 4 (spawn manual de obstáculo con F5)

---

## Contexto

Anteriormente F5 spawneaba un obstáculo de forma one-shot manual. Esta feature reemplaza
ese comportamiento por un sistema de **escalones de frecuencia** controlado por el director
en tiempo real. Sin acción del director, no aparecen obstáculos automáticamente.

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Activación del spawn con primer press (Priority: P1)

El director controla cuándo y con qué intensidad aparecen obstáculos en pantalla. Al
presionar F5 por primera vez, los obstáculos comienzan a aparecer automáticamente a
frecuencia baja.

**Why this priority**: Es el punto de entrada al sistema; sin esto el director no puede
activar el spawn.

**Independent Test**: Con el juego corriendo (sin obstáculos activos), presionar F5 una
vez y verificar que aparece un obstáculo de inmediato y luego continúan apareciendo cada
~6 segundos.

**Acceptance Scenarios**:

1. **Scenario**: Sin F5, sin spawn
   - **Given** el juego está corriendo y el director no ha presionado F5
   - **When** pasa el tiempo
   - **Then** no aparece ningún obstáculo automáticamente

2. **Scenario**: Primer press activa nivel 1
   - **Given** el spawn está inactivo (nivel 0)
   - **When** el director presiona F5 por primera vez
   - **Then** aparece inmediatamente un obstáculo (feedback visual de activación)
   - **Then** los obstáculos comienzan a aparecer automáticamente cada ~6 segundos

---

### User Story 2 — Escalado progresivo de frecuencia (Priority: P1)

Cada press adicional de F5 incrementa la frecuencia de spawn al siguiente nivel, con un
obstáculo inmediato como confirmación visual del cambio.

**Why this priority**: Es la funcionalidad central del director para crear tensión visual
sincronizada con la música.

**Independent Test**: Activar spawn (nivel 1) con F5. Presionar F5 tres veces más y
verificar que la frecuencia de aparición aumenta notablemente en cada press hasta el máximo.

**Acceptance Scenarios**:

1. **Scenario**: Press sube un nivel
   - **Given** el spawn está activo en nivel 1, 2 o 3
   - **When** el director presiona F5 una vez
   - **Then** la frecuencia de aparición aumenta al siguiente nivel (intervalos más cortos)
   - **Then** aparece un obstáculo inmediatamente como confirmación

2. **Scenario**: En máximo, F5 no tiene efecto
   - **Given** el spawn está en nivel máximo (4, ~0.75s entre spawns)
   - **When** el director presiona F5
   - **Then** la frecuencia no cambia (ya está al máximo)
   - **Then** no se spawna ningún obstáculo adicional por el press

---

### User Story 3 — Reset rápido con double-tap (Priority: P1)

El director puede detener completamente el spawn presionando F5 dos veces rápidamente,
volviendo al estado inicial sin obstáculos.

**Why this priority**: Le permite al director "limpiar" la pantalla en cualquier momento,
esencial para la edición del videoclip.

**Independent Test**: Con spawn activo en cualquier nivel, presionar F5 dos veces con
menos de 0.5s de diferencia y verificar que los obstáculos dejan de aparecer.

**Acceptance Scenarios**:

1. **Scenario**: Double-tap resetea a nivel 0
   - **Given** el spawn está activo en cualquier nivel
   - **When** el director presiona F5 dos veces rápidamente (dentro de ~0.5s)
   - **Then** el spawn se detiene completamente (nivel 0)
   - **Then** no aparecen más obstáculos hasta el próximo press de F5

2. **Scenario**: Sin obstáculos pendientes al resetear
   - **Given** el director ejecuta un double-tap
   - **When** el nivel vuelve a 0
   - **Then** el timer interno se cancela (no hay spawns retrasados pendientes)
   - **Then** la pantalla queda sin nuevos obstáculos de forma inmediata y consistente

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-NEW-01**: Sin acción del director, no deben aparecer obstáculos automáticamente.
- **FR-NEW-02**: F5 press simple escala la intensidad en 4 escalones:
  - Nivel 1 (Lento): intervalo ~6s
  - Nivel 2 (Medio): intervalo ~3s
  - Nivel 3 (Rápido): intervalo ~1.5s
  - Nivel 4 (Máximo): intervalo ~0.75s
- **FR-NEW-03**: Al activar (nivel 0→1) o escalar (nivel N→N+1), aparece un obstáculo
  de inmediato como feedback visual.
- **FR-NEW-04**: F5 double-tap (dos presses dentro de < 0.5s) detiene el spawn y
  resetea a nivel 0.
- **FR-NEW-05**: En nivel máximo (4), presses adicionales de F5 no producen ningún
  efecto (ni spawn inmediato ni cambio de frecuencia).

### Tabla de niveles de intensidad

| Nivel | Estado  | Intervalo entre spawns |
|-------|---------|------------------------|
| 0     | Off     | No spawna              |
| 1     | Lento   | ~6s                    |
| 2     | Medio   | ~3s                    |
| 3     | Rápido  | ~1.5s                  |
| 4     | Máximo  | ~0.75s                 |

### Key Entities

- **ObstacleDirector** (parte del sistema Director existente): Gestiona el nivel de
  intensidad actual, el timer de spawn, y la lógica de double-tap. Reemplaza el spawn
  one-shot manual anterior.
- **Nivel de Intensidad** (int 0–4): Estado interno del director. Controla el intervalo
  del timer de spawn.
- **Timer de Spawn**: Timer activo solo cuando el nivel > 0. Se reinicia al cambiar de
  nivel; se detiene al resetear.
- **Ventana de Double-tap**: Período de ~0.5s después de un press durante el cual un
  segundo press ejecuta el reset en lugar de subir de nivel.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-NEW-01**: Cada press de F5 produce un cambio visible en la densidad de
  obstáculos en ≤ 1 ciclo del nuevo intervalo.
- **SC-NEW-02**: El double-tap detiene el spawn de forma consistente; no quedan spawns
  retrasados pendientes después del reset.
- **SC-NEW-03**: El estado inicial del juego no genera ningún obstáculo sin intervención
  del director.
- **SC-NEW-04**: La transición entre niveles es inmediata (el nuevo intervalo aplica
  desde el spawn siguiente al press).

---

## Edge Cases

- ¿Qué pasa si el director hace double-tap estando en nivel 0? → No tiene efecto (ya
  está inactivo; no hay spawn que detener).
- ¿Qué pasa si hay un obstáculo ya en vuelo cuando se resetea a nivel 0? → Los
  obstáculos ya spawneados terminan su trayectoria normalmente; el reset solo detiene
  el spawn de nuevos.
- ¿Qué pasa si el director presiona F5 muy rápido más de dos veces? → El primer press
  sube un nivel; el segundo press (dentro de 0.5s) ejecuta el reset. Los presses
  adicionales se ignoran hasta que el período de double-tap expire.
- ¿Qué pasa si el director está en nivel 4 y hace double-tap? → Resetea a nivel 0
  correctamente (el double-tap tiene prioridad sobre "en nivel máximo no sube").
