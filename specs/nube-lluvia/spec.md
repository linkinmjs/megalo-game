# Feature Specification: Nube de lluvia — Efecto de presión hacia abajo (F2)

**Created**: 2026-02-24

## Contexto

La nube de lluvia es un efecto activable por el operador (director) durante el gameplay,
pensado para el videoclip. Al activarse, una nube aparece sobre el globo y descarga lluvia
que lo empuja hacia abajo. La nube sigue al globo torpemente, generando una sensación de
"persecución" visual.

La tecla de activación es **F2** (mapeada a la tecla numérica `2` del teclado).

---

## User Scenarios & Testing

### User Story 1 — Aparición y desaparición de la nube (Priority: P1)

El operador presiona F2 y una nube aparece sobre el globo. Al volver a presionar F2, la nube
desaparece. La transición es suave, con un fundido de entrada y salida.

**Why this priority**: Es el comportamiento visible principal. Sin la nube, el efecto no existe
como elemento visual.

**Independent Test**: Ejecutar el juego, presionar F2, verificar que aparece una nube. Presionar
F2 nuevamente, verificar que desaparece.

**Acceptance Scenarios**:

1. **Scenario**: Activación con fundido de entrada
   - **Given** el juego está corriendo y la nube está inactiva (invisible)
   - **When** el operador presiona F2
   - **Then** la nube aparece sobre el globo con un fundido de ~0.5 segundos (de transparente a opaca)
   - **Then** las partículas de lluvia comienzan a caer de inmediato

2. **Scenario**: Desactivación con fundido de salida
   - **Given** la nube está activa y visible
   - **When** el operador presiona F2 nuevamente
   - **Then** la nube desaparece con un fundido de ~0.5 segundos (de opaca a transparente)
   - **Then** las partículas de lluvia se detienen al inicio del fundido

---

### User Story 2 — Nube sigue al globo torpemente (Priority: P1)

Mientras está activa, la nube no se teletransporta ni se adhiere exactamente al globo: lo
sigue con retraso, como si flotara torpemente detrás de él. Siempre se mantiene unos píxeles
por encima del globo.

**Why this priority**: El seguimiento torpe le da carácter al efecto y lo hace más interesante
visualmente que una nube fija.

**Independent Test**: Con la nube activa, mover el globo rápidamente hacia los costados y
verificar que la nube tarda en alcanzarlo — se ve rezagada.

**Acceptance Scenarios**:

1. **Scenario**: Nube rezagada al mover el globo lateralmente
   - **Given** la nube está activa
   - **When** el jugador mueve el globo rápidamente hacia la derecha o izquierda
   - **Then** la nube sigue al globo pero con un retraso visible — no se mueve en sincronía exacta

2. **Scenario**: Nube siempre posicionada encima del globo
   - **Given** la nube está activa y el globo está en cualquier posición de pantalla
   - **When** se observa la posición vertical de la nube
   - **Then** la nube siempre está visiblemente por encima del globo (nunca al mismo nivel ni debajo)

3. **Scenario**: Nube alcanza al globo si este se detiene
   - **Given** la nube está activa y rezagada respecto al globo
   - **When** el globo deja de moverse lateralmente
   - **Then** la nube se aproxima gradualmente hacia la posición sobre el globo hasta alinearse

---

### User Story 3 — Presión de lluvia empuja al globo hacia abajo (Priority: P1)

Cuando el globo está directamente bajo la nube (dentro de su área de efecto), la lluvia aplica
una fuerza que lo empuja hacia abajo. Esta fuerza es sostenida y contrarrestable con el mechero.

**Why this priority**: Es la mecánica de gameplay. Sin la fuerza, la nube es solo decorativa.

**Independent Test**: Con la nube activa y el globo en reposo debajo de ella, observar que
el globo cae más rápido que sin nube. Activar el mechero y verificar que puede resistir
o contrarrestar la presión.

**Acceptance Scenarios**:

1. **Scenario**: Fuerza de bajada cuando el globo está bajo la nube
   - **Given** la nube está activa y el globo se encuentra dentro del área de la nube
   - **When** el jugador no usa el mechero
   - **Then** el globo cae perceptiblemente más rápido que sin nube activa

2. **Scenario**: Jugador puede resistir la presión con el mechero
   - **Given** la nube está activa y el globo está bajo su área de efecto
   - **When** el jugador activa el mechero (Espacio / W / ↑)
   - **Then** el globo puede mantenerse en altura o subir, resistiendo la presión de la lluvia

3. **Scenario**: Fuerza cesa al salir del área de la nube
   - **Given** la nube está activa y el globo estaba dentro de su área de efecto
   - **When** el globo se desplaza fuera del área cubierta por la nube (lateralmente)
   - **Then** la fuerza de lluvia cesa; el globo responde solo a gravedad e input

4. **Scenario**: Fuerza cesa al desactivar la nube
   - **Given** la nube está activa y el globo está bajo su área de efecto
   - **When** el operador presiona F2 para desactivar la nube
   - **Then** la fuerza de lluvia cesa de inmediato, aunque la nube aún esté en fundido de salida

---

### Edge Cases

- ¿Qué pasa si F2 se presiona mientras la nube está en fundido de entrada? → El toggle
  invierte: la nube inicia el fundido de salida desde su opacidad actual.
- ¿Qué pasa si el globo se mueve muy rápido y la nube queda muy rezagada? → La nube
  sigue acercándose gradualmente; si el globo frena, la nube lo alcanza. El retraso no tiene
  límite máximo — el efecto visual del "perseguidor torpe" se mantiene.
- ¿Qué pasa si el jugador pausa el juego con la nube activa? → Al reanudar, la nube
  sigue activa en el mismo estado y posición.
- ¿Qué pasa si el globo está en el borde superior de pantalla? → La nube queda parcialmente
  fuera de pantalla (arriba), pero sigue emitiendo partículas y fuerza normalmente.

---

## Requirements

### Functional Requirements

- **FR-RAIN-001**: Al presionar F2, la nube DEBE aparecer sobre el globo con un fundido de
  ~0.5 segundos.
- **FR-RAIN-002**: Al presionar F2 nuevamente, la nube DEBE desaparecer con un fundido de
  ~0.5 segundos.
- **FR-RAIN-003**: Mientras está activa, la nube DEBE seguir la posición horizontal del globo
  con retraso perceptible (lerp, no instantáneo).
- **FR-RAIN-004**: La nube DEBE mantenerse siempre por encima del globo (offset vertical fijo,
  ~200px hacia arriba).
- **FR-RAIN-005**: Mientras el globo esté dentro del área de efecto de la nube activa, DEBE
  recibir una fuerza continua hacia abajo.
- **FR-RAIN-006**: La fuerza hacia abajo DEBE cesar al instante cuando la nube se desactiva,
  independientemente del fundido visual.
- **FR-RAIN-007**: La fuerza hacia abajo DEBE cesar cuando el globo sale lateralmente del área
  cubierta por la nube.
- **FR-RAIN-008**: La fuerza de lluvia DEBE ser contrarrestable mediante el mechero del jugador.
- **FR-RAIN-009**: Las partículas de lluvia DEBEN activarse al encender la nube y detenerse
  al apagarla.

### Key Entities

- **Nube (RainCloud)**: Elemento visual que sigue al globo desde arriba. Controla las
  partículas y el área de efecto.
- **Área de efecto**: Zona rectangular debajo de la nube. Mientras el globo está dentro
  y la nube está activa, se aplica la fuerza de lluvia.
- **Fuerza de lluvia**: Empuje vertical hacia abajo sobre el globo. Se suma a la gravedad
  existente.
- **Partículas de lluvia**: Efecto visual de gotas cayendo, activo solo mientras la nube
  está encendida.

---

## Success Criteria

### Measurable Outcomes

- **SC-RAIN-001**: La nube aparece y desaparece con fundido visible de ~0.5s — sin cortes
  abruptos ni pop-in.
- **SC-RAIN-002**: Con la nube activa y el globo en reposo bajo ella (sin mechero), el globo
  cae perceptiblemente más rápido que sin nube.
- **SC-RAIN-003**: Al mover el globo lateralmente con rapidez, la nube tarda al menos 0.5s
  en aproximarse a su nueva posición objetivo — el rezago es claramente visible.
- **SC-RAIN-004**: Al desactivar la nube, la fuerza cesa de inmediato (el globo deja de caer
  más rápido antes de que termine el fundido visual).
