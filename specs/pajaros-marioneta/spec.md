# Feature Specification: Pájaros Marioneta — Animación de entrada/salida (F4)

**Created**: 2026-02-23

## Contexto

Esta feature **reemplaza** el comportamiento visual de la bandada de pájaros (F4).

El comportamiento anterior (los pájaros aparecen/desaparecen instantáneamente como capa de
parallax sin animación) queda **deprecated**.

Los pájaros ahora descienden desde arriba de la pantalla como **marionetas o adornos colgados**:
cada pájaro tiene un hilo visible que lo conecta a un punto fuera de la pantalla (arriba),
y la impresión es la de marionetas siendo bajadas a escena. Al desactivar, ascienden de vuelta.

La tecla de activación (F4) y la señal global (`birds_toggled`) no cambian.

---

## User Scenarios & Testing

### User Story 1 — Animación de entrada y salida (Priority: P1)

Al presionar F4, los pájaros descienden desde arriba de la pantalla con una animación suave y
teatral. Al presionar F4 nuevamente, ascienden de vuelta y desaparecen por el borde superior.

**Why this priority**: Es el cambio visual principal que da identidad al evento. Sin animación,
la activación es abrupta y no comunica el concepto de "marioneta".

**Independent Test**: Ejecutar el juego, presionar F4, y observar que los pájaros bajan desde
arriba con movimiento suave. Presionar F4 nuevamente y observar que suben.

**Acceptance Scenarios**:

1. **Scenario**: Descenso desde arriba al activar
   - **Given** el juego está corriendo y los pájaros están inactivos (fuera de pantalla, arriba)
   - **When** el operador presiona F4
   - **Then** los pájaros descienden desde el borde superior de la pantalla con movimiento
     suave y uniforme
   - **Then** la animación de descenso dura entre 0.5 y 1.5 segundos
   - **Then** los pájaros se detienen en una posición estable dentro de la pantalla

2. **Scenario**: Ascenso al desactivar
   - **Given** los pájaros están visibles y en su posición estable
   - **When** el operador presiona F4 nuevamente
   - **Then** los pájaros suben hacia el borde superior de la pantalla con movimiento suave
   - **Then** los pájaros y sus hilos desaparecen por arriba de la pantalla
   - **Then** la animación de ascenso dura entre 0.5 y 1.5 segundos

---

### User Story 2 — Efecto visual de hilo/marioneta (Priority: P1)

Cada pájaro tiene un hilo fino visible que sube desde su parte superior hacia afuera de la
pantalla. El conjunto da la impresión de marionetas o adornos colgados de hilos.

**Why this priority**: Es el elemento visual diferenciador. Sin el hilo, los pájaros son
simplemente una bandada volando; con el hilo se convierten en marionetas.

**Independent Test**: Con los pájaros visibles, observar que cada pájaro tiene una línea
delgada que sube hacia el borde superior de la pantalla.

**Acceptance Scenarios**:

1. **Scenario**: Hilo visible sobre cada pájaro
   - **Given** los pájaros están activos y en pantalla
   - **When** se observa la escena
   - **Then** cada pájaro tiene una línea delgada visible que sale de su parte superior
     y se extiende hacia arriba hasta salir del borde de la pantalla
   - **Then** los hilos son finos y de color oscuro/tenue (del mismo tono que las siluetas)

2. **Scenario**: Hilo y pájaro se mueven como una unidad
   - **Given** los pájaros están animándose (subiendo o bajando)
   - **When** se observa el movimiento
   - **Then** el hilo y el pájaro se desplazan juntos de forma coherente

---

### User Story 3 — Movimiento horizontal mientras están visibles (Priority: P2)

Mientras los pájaros están en su posición estable en pantalla, se desplazan horizontalmente
de forma continua, manteniendo la sensación de bandada en vuelo.

**Why this priority**: Sin movimiento horizontal los pájaros son adornos estáticos, lo cual
pierde el dinamismo del evento.

**Independent Test**: Con los pájaros visibles y en su posición final, observar que se
desplazan horizontalmente en loop.

**Acceptance Scenarios**:

1. **Scenario**: Movimiento horizontal en loop
   - **Given** los pájaros terminaron de descender y están en posición estable
   - **When** el tiempo pasa
   - **Then** los pájaros (con sus hilos) se desplazan horizontalmente de forma continua
   - **Then** el movimiento hace loop: los pájaros que salen por un borde reaparecen por el otro

---

### Edge Cases

- ¿Qué pasa si F4 se presiona durante la animación de descenso? → Se invierte: los pájaros
  comienzan a ascender desde la posición actual.
- ¿Qué pasa si F4 se presiona durante la animación de ascenso? → Se invierte: los pájaros
  comienzan a descender desde la posición actual.
- ¿Cuántos pájaros hay? → El número es configurable vía `@export`; 6–10 es el rango óptimo.
- ¿Los hilos desaparecen cuando los pájaros salen de pantalla? → Los hilos forman parte del
  mismo objeto que el pájaro, así que suben y desaparecen junto con él.

---

## Requirements

### Functional Requirements

- **FR-BIRD-001**: Al activar F4, los pájaros DEBEN descender desde el borde superior con
  animación suave (duración 0.5–1.5s).
- **FR-BIRD-002**: Cada pájaro DEBE tener un hilo visible que conecta su parte superior
  con un punto fuera de la pantalla (arriba).
- **FR-BIRD-003**: El hilo y el pájaro DEBEN moverse como una unidad durante todas las
  animaciones y durante el movimiento horizontal.
- **FR-BIRD-004**: Al desactivar F4, los pájaros DEBEN ascender hacia el borde superior
  con animación suave y desaparecer.
- **FR-BIRD-005**: Mientras los pájaros están en posición estable, DEBEN moverse
  horizontalmente en loop.
- **FR-BIRD-006**: Esta feature REEMPLAZA el comportamiento de aparición/desaparición
  instantánea anterior.
- **FR-BIRD-007**: La tecla F4 y la señal `birds_toggled` NO cambian.

### Key Entities

- **Pájaro marioneta (BirdMarionette)**: Silueta de pájaro con un hilo visible arriba.
  Tiene posición vertical animable (descenso/ascenso) y movimiento horizontal.
- **Hilo**: Línea delgada que sale de la parte superior de cada pájaro hacia arriba
  (fuera de pantalla).
- **Bandada**: Grupo de 6–10 pájaros marioneta distribuidos horizontalmente.

---

## Success Criteria

### Measurable Outcomes

- **SC-BIRD-001**: La animación de descenso es visualmente suave (sin pop-in ni saltos).
- **SC-BIRD-002**: Los hilos son claramente visibles encima de cada pájaro.
- **SC-BIRD-003**: La duración de la animación de entrada/salida está entre 0.5 y 1.5 segundos.
- **SC-BIRD-004**: Los pájaros se mueven horizontalmente en loop sin glitches mientras
  están activos y estables.
