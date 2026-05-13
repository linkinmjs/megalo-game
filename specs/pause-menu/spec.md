# Feature Specification: Menú de Pausa

**Created**: 2026-02-24

## Contexto

El menú de pausa se activa durante el gameplay con la tecla **Escape**. Detiene
la acción del juego y muestra un overlay semitransparente con tres opciones:
reanudar, ir a configuración de audio, o salir al menú principal.

Cuando se pausa, la música se desvanece gradualmente; al reanudar, vuelve con
un fundido. El juego permanece completamente detenido mientras el overlay
está visible.

---

## User Scenarios & Testing

### User Story 1 — Pausar y reanudar el juego (Priority: P1)

El jugador puede pausar el juego en cualquier momento con Escape. Todo se
detiene: el globo, los obstáculos, los efectos. Presionar Escape nuevamente
(o el botón Reanudar) vuelve al juego donde se dejó.

**Why this priority**: Es la función principal del menú. Sin pausa, el jugador
no puede interrumpir la partida.

**Independent Test**: Durante el gameplay presionar Escape, verificar que todo
se detiene, luego reanudar y verificar que el juego continúa normalmente.

**Acceptance Scenarios**:

1. **Scenario**: Escape pausa el juego
   - **Given** el jugador está en el gameplay activo
   - **When** presiona Escape
   - **Then** el juego se detiene completamente (el globo, obstáculos y efectos
     quedan congelados)
   - **Then** aparece un overlay semitransparente con las opciones de pausa

2. **Scenario**: Escape reanuda el juego
   - **Given** el menú de pausa está activo (panel principal visible)
   - **When** el jugador presiona Escape
   - **Then** el overlay desaparece y el juego se reanuda desde el estado exacto
     en que estaba al pausar

3. **Scenario**: Botón Reanudar funciona igual que Escape
   - **Given** el menú de pausa está activo
   - **When** el jugador hace click en "Reanudar"
   - **Then** el overlay desaparece y el juego continúa

---

### User Story 2 — Fade de música al pausar y reanudar (Priority: P1)

Al pausar, la música se desvanece gradualmente hasta el silencio. Al reanudar,
vuelve con un fundido más rápido. Esto hace que la pausa se sienta como un
momento deliberado, no un corte brusco.

**Why this priority**: Sin el fade, la música se corta abruptamente al pausar,
lo que rompe la experiencia audiovisual.

**Independent Test**: Pausar durante el gameplay con música sonando y verificar
que el volumen baja suavemente. Reanudar y verificar que vuelve gradualmente.

**Acceptance Scenarios**:

1. **Scenario**: Música baja suavemente al pausar
   - **Given** el juego está activo y hay música sonando
   - **When** el jugador presiona Escape para pausar
   - **Then** el volumen de la música baja gradualmente hasta el silencio
     (en ~1 segundo)
   - **Then** la música queda completamente silenciada (no solo baja de volumen)

2. **Scenario**: Música vuelve al reanudar
   - **Given** el juego está pausado y la música está silenciada
   - **When** el jugador reanuda (Escape o botón)
   - **Then** la música vuelve gradualmente al volumen configurado en ~0.5 segundos
   - **Then** el gameplay y la música están sincronizados una vez completado el fundido

---

### User Story 3 — Acceder a opciones desde la pausa (Priority: P2)

Desde el menú de pausa el jugador puede abrir las opciones de audio sin
salir del juego. Las opciones aparecen como un panel alternativo dentro del
mismo overlay — no hay cambio de escena ni fundido.

**Why this priority**: Permite ajustar el audio sin perder la partida actual.

**Independent Test**: Pausar el juego, abrir Settings, ajustar un slider,
presionar Volver y verificar que el panel de pausa vuelve a mostrarse.

**Acceptance Scenarios**:

1. **Scenario**: Botón Configuración abre el panel de opciones en pausa
   - **Given** el menú de pausa está activo
   - **When** el jugador hace click en "Configuración" (Settings)
   - **Then** el panel de pausa desaparece y en su lugar aparece el panel de
     opciones con los sliders de Música y SFX — sin fundido, sin cambio de escena

2. **Scenario**: Volver desde opciones regresa al panel de pausa
   - **Given** el panel de opciones está visible dentro de la pausa
   - **When** el jugador hace click en "Volver" o presiona Escape
   - **Then** el panel de opciones desaparece y vuelve el panel de pausa principal

3. **Scenario**: Los cambios de opciones se aplican en tiempo real en pausa
   - **Given** el panel de opciones está visible dentro de la pausa
   - **When** el jugador mueve el slider de Música
   - **Then** el volumen de la música cambia inmediatamente (aunque esté en silencio
     por la pausa, el cambio quedará activo al reanudar)

---

### User Story 4 — Salir al menú principal desde la pausa (Priority: P2)

El jugador puede abandonar la partida actual y volver al menú principal sin
cerrar el juego. La partida se descarta — no hay guardado automático.

**Why this priority**: Sin esta opción, el jugador tendría que cerrar el juego
para volver al menú.

**Independent Test**: Pausar el juego y presionar "Salir al menú". Verificar
que el menú principal carga correctamente.

**Acceptance Scenarios**:

1. **Scenario**: Salir al menú descarta la partida y vuelve al inicio
   - **Given** el menú de pausa está activo
   - **When** el jugador hace click en "Salir al menú"
   - **Then** el juego vuelve al menú principal con una transición (fundido a negro)
   - **Then** la partida actual se descarta completamente

2. **Scenario**: El menú principal carga en estado limpio
   - **Given** el jugador salió al menú desde la pausa
   - **When** el menú principal aparece
   - **Then** el juego está en estado inicial — listo para iniciar una nueva partida

---

### Edge Cases

- ¿Qué pasa si el jugador presiona Escape mientras está en el panel de opciones
  dentro de la pausa? → Vuelve al panel de pausa (no reanuda el juego).
- ¿Qué pasa si el jugador pausa mientras hay efectos del director activos
  (nube, aspiradora, pájaros)? → El juego se detiene con todos los efectos
  en su estado actual. Al reanudar, los efectos siguen activos.
- ¿Qué pasa si el jugador pausa durante el glitch previo al fake crash? →
  El fake crash tiene prioridad — la secuencia de crash no es pausable.
- ¿Puede el jugador pausar en el menú principal o en la pantalla de opciones?
  → No. El menú de pausa solo está disponible durante el gameplay activo.

---

## Requirements

### Functional Requirements

- **FR-PAUSE-001**: La tecla Escape DEBE pausar el juego durante el gameplay,
  mostrando el overlay de pausa.
- **FR-PAUSE-002**: Al pausar, el juego DEBE detenerse completamente (incluyendo
  globo, obstáculos y todos los efectos del director).
- **FR-PAUSE-003**: Al pausar, la música DEBE desvanecerse gradualmente hasta
  el silencio (~1 segundo) y luego quedar silenciada.
- **FR-PAUSE-004**: El menú de pausa DEBE mostrar tres opciones: "Reanudar",
  "Configuración" y "Salir al menú".
- **FR-PAUSE-005**: "Reanudar" y Escape (con panel de pausa visible) DEBEN
  reanudar el juego y desvanecerse el overlay.
- **FR-PAUSE-006**: Al reanudar, la música DEBE volver gradualmente al volumen
  configurado (~0.5 segundos).
- **FR-PAUSE-007**: "Configuración" DEBE mostrar el panel de opciones embebido
  (sin cambio de escena) en lugar del panel de pausa.
- **FR-PAUSE-008**: Escape con el panel de opciones visible DEBE volver al
  panel de pausa — no reanudar el juego.
- **FR-PAUSE-009**: "Salir al menú" DEBE desactivar la pausa, hacer un fundido
  a negro y cargar el menú principal.
- **FR-PAUSE-010**: El menú de pausa DEBE seguir recibiendo input incluso
  cuando el juego está pausado (el overlay no se congela junto con el juego).

### Key Entities

- **Overlay de pausa**: Capa visual semitransparente sobre el gameplay. Visible
  solo mientras el juego está pausado.
- **Panel de pausa**: Panel con los tres botones (Reanudar, Configuración, Salir).
- **Panel de opciones embebido**: Panel alternativo con sliders de audio,
  visible dentro del overlay de pausa al presionar Configuración.
- **Fade de música**: Transición de volumen al pausar (lento, ~1s) y reanudar
  (rápido, ~0.5s).

---

## Success Criteria

### Measurable Outcomes

- **SC-PAUSE-001**: Al presionar Escape, el overlay de pausa aparece y el juego
  se detiene en menos de un frame — sin delay perceptible.
- **SC-PAUSE-002**: El fade de música al pausar es suave y dura ~1 segundo —
  no hay corte brusco audible.
- **SC-PAUSE-003**: El fade de música al reanudar dura ~0.5 segundos — el
  volumen vuelve al nivel configurado sin saltos.
- **SC-PAUSE-004**: La navegación entre panel de pausa y panel de opciones es
  instantánea — sin transición ni carga perceptible.
- **SC-PAUSE-005**: Al salir al menú principal desde la pausa, el menú carga
  completamente en ≤ 1 segundo.
