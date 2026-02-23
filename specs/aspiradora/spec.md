# Feature Specification: Aspiradora — Efecto de succión (reemplaza viento F3)

**Created**: 2026-02-23

## Contexto

Esta feature **reemplaza** el efecto de viento (F3) existente.

El comportamiento anterior (partículas de viento que empujan al globo hacia la derecha) queda
**deprecated** y es reemplazado por una aspiradora gigante que asoma desde el borde izquierdo
de la pantalla y succiona al globo hacia ella.

La tecla de activación (F3) y la señal global (`wind_toggled`) no cambian.

---

## User Scenarios & Testing

### User Story 1 — Aparición visual de la aspiradora (Priority: P1)

El operador presiona F3 y una aspiradora gigante aparece deslizándose desde el borde izquierdo
de la pantalla. La aspiradora es visualmente grande y reconocible, mostrando solo su boca/tubo
asomando por el costado izquierdo.

**Why this priority**: Es el cambio visual principal. Sin la aspiradora, el efecto no tiene
identidad propia y no se diferencia del viento anterior.

**Independent Test**: Ejecutar el juego, presionar F3, y verificar que aparece un elemento
visual desde el borde izquierdo con animación de entrada.

**Acceptance Scenarios**:

1. **Scenario**: Aparición con animación de entrada
   - **Given** el juego está corriendo y la aspiradora está inactiva
   - **When** el operador presiona F3
   - **Then** una aspiradora gigante entra en pantalla deslizándose desde el borde izquierdo,
     mostrando su boca/tubo asomando por el costado
   - **Then** la animación de entrada dura ≤ 0.5 segundos

2. **Scenario**: Desaparición con animación de salida
   - **Given** la aspiradora está activa y visible en pantalla
   - **When** el operador presiona F3 nuevamente
   - **Then** la aspiradora sale de pantalla deslizándose hacia el borde izquierdo
   - **Then** la animación de salida dura ≤ 0.5 segundos

---

### User Story 2 — Fuerza de succión sobre el globo (Priority: P1)

Mientras la aspiradora está activa, el globo es atraído hacia la izquierda (hacia la boca de la
aspiradora). La fuerza es sostenida pero no aplastante — el jugador puede contrarrestarla
moviéndose hacia la derecha.

**Why this priority**: Es la mecánica de gameplay. Sin la fuerza, la aspiradora es solo decorativa.

**Independent Test**: Con la aspiradora activa, soltar los controles y observar que el globo
deriva hacia la izquierda. Presionar D o → y verificar que puede resistir o contrarrestar
la succión.

**Acceptance Scenarios**:

1. **Scenario**: Globo atraído hacia la aspiradora sin input
   - **Given** la aspiradora está activa y el jugador no presiona teclas laterales
   - **When** el tiempo pasa
   - **Then** el globo deriva gradualmente hacia la izquierda (hacia la boca)
   - **Then** la velocidad de deriva es perceptible pero no instantánea

2. **Scenario**: Jugador puede resistir la succión
   - **Given** la aspiradora está activa
   - **When** el jugador presiona D o Flecha Derecha
   - **Then** el globo puede moverse hacia la derecha, resistiendo o superando la fuerza de succión

3. **Scenario**: Fuerza cesa al desactivar
   - **Given** la aspiradora estaba activa y se desactivó
   - **When** la animación de salida termina
   - **Then** la fuerza de succión cesa completamente; el globo responde solo al input del jugador

---

### User Story 3 — Efecto visual de partículas de succión (Priority: P2)

Mientras la aspiradora está activa, se ven partículas fluyendo desde la pantalla hacia la boca
de la aspiradora (de derecha a izquierda), reforzando visualmente la sensación de succión.

**Why this priority**: Refuerza el storytelling visual. Sin partículas el efecto de succión
es mecánicamente correcto pero visualmente poco expresivo.

**Independent Test**: Con la aspiradora activa, observar partículas moviéndose claramente
de derecha a izquierda.

**Acceptance Scenarios**:

1. **Scenario**: Partículas de succión visibles y dirigidas
   - **Given** la aspiradora está activa
   - **When** se observa la pantalla
   - **Then** se ven partículas moviéndose de derecha a izquierda, como si fueran
     absorbidas por la aspiradora

2. **Scenario**: Partículas se detienen al desactivar
   - **Given** la aspiradora se desactiva
   - **When** comienza la animación de salida
   - **Then** las partículas nuevas dejan de generarse; las existentes completan
     su trayectoria o desaparecen

---

### Edge Cases

- ¿Qué pasa si F3 se presiona mientras la aspiradora está en animación de entrada? → Se
  inicia la animación de salida inmediatamente desde la posición actual.
- ¿Qué pasa si el globo está en el borde izquierdo con la aspiradora activa? → El globo
  no puede atravesar el borde (límites de pantalla siguen activos); queda en el margen izquierdo.
- ¿Qué pasa si el jugador pausa el juego con la aspiradora activa? → Al reanudar, la
  aspiradora sigue activa en el mismo estado.

---

## Requirements

### Functional Requirements

- **FR-ASP-001**: Al presionar F3, DEBE aparecer un elemento visual (aspiradora) deslizándose
  desde el borde izquierdo de la pantalla (animación ≤ 0.5s).
- **FR-ASP-002**: Mientras la aspiradora está activa, el globo DEBE recibir una fuerza de
  atracción constante hacia la izquierda.
- **FR-ASP-003**: La fuerza de succión DEBE ser contrarrestable mediante el input del jugador
  (movimiento hacia la derecha).
- **FR-ASP-004**: Se DEBEN mostrar partículas moviéndose de derecha a izquierda mientras la
  aspiradora está activa.
- **FR-ASP-005**: Al desactivar F3, la aspiradora DEBE salir de pantalla hacia la izquierda
  (animación ≤ 0.5s) y la fuerza DEBE cesar.
- **FR-ASP-006**: Esta feature REEMPLAZA completamente el efecto de viento anterior
  (partículas de viento + fuerza hacia la derecha).
- **FR-ASP-007**: La tecla F3 y la señal `wind_toggled` NO cambian — solo cambia el efecto.

### Key Entities

- **Aspiradora (VacuumEffect)**: Elemento visual que asoma desde el borde izquierdo.
  Controla la fuerza de succión y las partículas.
- **Partículas de succión**: Fluyen de derecha a izquierda mientras la aspiradora está activa.
- **Fuerza de succión**: Atracción horizontal hacia la izquierda sobre el globo.

---

## Success Criteria

### Measurable Outcomes

- **SC-ASP-001**: La aspiradora aparece en pantalla en ≤ 0.5s desde F3.
- **SC-ASP-002**: Con la aspiradora activa y sin input, el globo deriva visiblemente
  hacia la izquierda en los primeros 2 segundos.
- **SC-ASP-003**: Las partículas de succión son visibles y claramente dirigidas hacia
  la izquierda.
- **SC-ASP-004**: Al desactivar, la aspiradora desaparece de pantalla en ≤ 0.5s.
