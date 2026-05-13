# Feature Specification: Menú Principal

**Created**: 2026-02-24

## Contexto

El menú principal es la primera pantalla que ve el jugador al iniciar el juego.
Desde aquí puede iniciar una partida o acceder a la configuración de audio.
Reproduce un sonido de ambientación mientras está activo.

---

## User Scenarios & Testing

### User Story 1 — Iniciar una partida (Priority: P1)

El jugador llega al menú principal y puede comenzar a jugar con un solo click.
La transición al juego es fluida, con un fundido a negro.

**Why this priority**: Es la acción principal del menú. Sin ella, el juego no
puede comenzar.

**Independent Test**: Abrir el juego, llegar al menú principal, presionar Play
y verificar que la pantalla del juego carga.

**Acceptance Scenarios**:

1. **Scenario**: Play lleva al juego con transición
   - **Given** el jugador está en el menú principal
   - **When** hace click en el botón "Play"
   - **Then** la pantalla hace un fundido a negro y carga la escena del juego

2. **Scenario**: El menú no es accesible durante el juego
   - **Given** el jugador está en la pantalla del juego
   - **When** observa la pantalla
   - **Then** el menú principal no está visible ni accesible desde el gameplay
     (solo desde el menú de pausa → Salir al menú)

---

### User Story 2 — Acceder a la configuración (Priority: P1)

El jugador puede ir a la pantalla de opciones desde el menú principal para
ajustar los volúmenes de música y SFX antes de jugar.

**Why this priority**: Permite configurar el audio antes de iniciar. Sin este
flujo, el jugador tendría que entrar al juego para acceder a opciones.

**Independent Test**: En el menú principal, presionar Settings y verificar que
aparece la pantalla de opciones.

**Acceptance Scenarios**:

1. **Scenario**: Settings navega a la pantalla de opciones
   - **Given** el jugador está en el menú principal
   - **When** hace click en el botón "Settings"
   - **Then** la pantalla hace un fundido a negro y carga la pantalla de opciones

2. **Scenario**: Volver desde opciones regresa al menú principal
   - **Given** el jugador está en la pantalla de opciones (habiendo llegado desde el menú principal)
   - **When** hace click en "Volver" (Back)
   - **Then** vuelve al menú principal con fundido a negro

---

### User Story 3 — Audio de ambientación (Priority: P2)

Mientras el menú principal está activo, suena un audio de ambientación en loop.
Crea atmósfera mientras el jugador decide qué hacer.

**Why this priority**: Refuerzo atmosférico. El menú funciona sin él, pero la
experiencia es más completa con sonido.

**Independent Test**: Abrir el juego y verificar que hay sonido reproduciéndose
en el menú principal.

**Acceptance Scenarios**:

1. **Scenario**: Ambient audio suena al entrar al menú
   - **Given** el jugador llega al menú principal
   - **When** espera un momento
   - **Then** se escucha un sonido de ambientación reproduciéndose en loop

2. **Scenario**: Si no hay audio configurado, no hay error
   - **Given** no hay archivo de audio asignado al reproductor de ambientación
   - **When** el menú principal carga
   - **Then** el menú funciona normalmente en silencio — sin crash ni mensaje de error

---

### Edge Cases

- ¿Qué pasa si el jugador hace click en Play mientras hay una transición activa?
  → La transición no se interrumpe; un segundo click no tiene efecto.
- ¿Qué pasa si el jugador llega al menú principal después de salir desde la pausa?
  → El menú principal carga normalmente con su audio de ambientación.

---

## Requirements

### Functional Requirements

- **FR-MMENU-001**: Al iniciar el juego, la primera pantalla visible DEBE ser el menú principal.
- **FR-MMENU-002**: El menú DEBE mostrar al menos dos botones: "Play" y "Settings".
- **FR-MMENU-003**: Al presionar "Play", DEBE iniciarse una transición (fundido a negro)
  y cargarse la escena del juego.
- **FR-MMENU-004**: Al presionar "Settings", DEBE iniciarse una transición y cargarse la
  pantalla de opciones. El menú principal DEBE quedar registrado como escena de retorno.
- **FR-MMENU-005**: Si hay un audio de ambientación configurado, DEBE reproducirse en loop
  al entrar al menú. Si no hay audio, el menú DEBE funcionar en silencio sin error.

### Key Entities

- **Menú principal**: Pantalla de inicio del juego. Punto de entrada obligatorio.
- **Botón Play**: Inicia el juego con transición.
- **Botón Settings**: Navega a la pantalla de opciones.
- **Audio de ambientación**: Sonido en loop activo mientras el menú está visible.

---

## Success Criteria

### Measurable Outcomes

- **SC-MMENU-001**: El juego arranca directamente en el menú principal — sin pasar por
  ninguna otra pantalla.
- **SC-MMENU-002**: La transición de Play al juego se completa en ≤ 1 segundo.
- **SC-MMENU-003**: La transición de Settings a opciones se completa en ≤ 1 segundo.
- **SC-MMENU-004**: Al volver de opciones, el menú principal carga correctamente
  con su audio de ambientación activo.
