# Feature Specification: Pantalla de Opciones (Settings)

**Created**: 2026-02-24

## Contexto

La pantalla de opciones permite al jugador ajustar los volúmenes de música y
efectos de sonido (SFX). Es accesible desde dos lugares:

- **Desde el menú principal**: como pantalla completa independiente.
- **Desde el menú de pausa**: como panel embebido dentro del overlay de pausa
  (sin cambio de escena).

En ambos casos, los controles y el comportamiento son idénticos. Los cambios
se aplican en tiempo real y se guardan automáticamente — no hay botón "Aplicar".

---

## User Scenarios & Testing

### User Story 1 — Ajustar el volumen de música (Priority: P1)

El jugador puede subir o bajar el volumen de la música del juego usando un
slider. El cambio es inmediato y se guarda automáticamente.

**Why this priority**: Control de música es la configuración más importante
para una experiencia personalizada.

**Independent Test**: Abrir opciones, mover el slider de música y verificar
que el volumen cambia en tiempo real.

**Acceptance Scenarios**:

1. **Scenario**: Mover el slider cambia el volumen en tiempo real
   - **Given** el jugador está en la pantalla de opciones
   - **When** arrastra el slider de "Música" hacia la derecha o izquierda
   - **Then** el volumen de la música cambia inmediatamente mientras se arrastra

2. **Scenario**: El valor se guarda automáticamente
   - **Given** el jugador ajustó el slider de música a un valor determinado
   - **When** cierra el juego y lo vuelve a abrir
   - **Then** el slider de música aparece en el mismo valor que dejó,
     y la música suena con ese volumen desde el inicio

---

### User Story 2 — Ajustar el volumen de efectos de sonido (Priority: P1)

El jugador puede ajustar el volumen de los efectos de sonido (SFX) de forma
independiente a la música.

**Why this priority**: Permite balance independiente entre música y SFX,
necesario para diferentes contextos de uso.

**Independent Test**: Mover el slider de SFX y verificar que el volumen de
efectos de sonido cambia.

**Acceptance Scenarios**:

1. **Scenario**: Slider de SFX controla solo los efectos de sonido
   - **Given** el jugador está en opciones
   - **When** mueve el slider de "SFX"
   - **Then** el volumen de los efectos de sonido cambia; la música no se ve afectada

2. **Scenario**: Música y SFX son independientes
   - **Given** el jugador tiene música al 50% y SFX al 100%
   - **When** abre el juego nuevamente
   - **Then** los sliders muestran 50% y 100% respectivamente — cada valor persiste por separado

---

### User Story 3 — Sliders cargados con valores guardados al entrar (Priority: P1)

Al abrir la pantalla de opciones, los sliders ya están posicionados en los
valores que el jugador guardó la última vez. No hay que reconfigurar en cada sesión.

**Why this priority**: Sin persistencia, el jugador reconfigura el audio cada
vez que abre el juego — experiencia degradada.

**Independent Test**: Configurar volúmenes, cerrar el juego, volver a abrirlo
y verificar que los sliders están en los valores guardados.

**Acceptance Scenarios**:

1. **Scenario**: Primera apertura usa valores por defecto
   - **Given** es la primera vez que el jugador abre opciones (sin archivo guardado)
   - **When** entra a la pantalla de opciones
   - **Then** ambos sliders están al máximo (volumen 100%)

2. **Scenario**: Aperturas posteriores usan valores guardados
   - **Given** el jugador guardó volúmenes personalizados en sesiones anteriores
   - **When** abre la pantalla de opciones
   - **Then** los sliders están en los valores guardados y el audio ya suena con esos
     volúmenes — no hay un momento con volumen incorrecto al entrar

---

### User Story 4 — Volver a la pantalla anterior (Priority: P1)

La pantalla de opciones siempre tiene un camino de vuelta. Si se llegó desde
el menú principal, vuelve al menú principal. Si se llegó desde la pausa,
vuelve al panel de pausa — sin cambio de escena.

**Why this priority**: Sin un "Volver", el jugador queda atrapado en opciones.

**Independent Test**: Entrar a opciones desde el menú principal, presionar
"Volver" y verificar que regresa al menú principal.

**Acceptance Scenarios**:

1. **Scenario**: Volver desde opciones (acceso desde menú principal)
   - **Given** el jugador llegó a opciones desde el menú principal
   - **When** presiona el botón "Volver" (Back)
   - **Then** vuelve al menú principal con una transición (fundido a negro)

2. **Scenario**: Volver desde opciones embebidas en pausa
   - **Given** el jugador está en el panel de opciones dentro del menú de pausa
   - **When** presiona "Volver" o la tecla Escape
   - **Then** vuelve al panel de pausa — sin cambio de escena, sin fundido

---

### Edge Cases

- ¿Qué pasa si el archivo de configuración está corrupto o es inaccesible? →
  Los sliders cargan en valores por defecto (100% para ambos) y el juego
  funciona normalmente.
- ¿Qué pasa si el jugador mueve el slider rápidamente muchas veces? → Cada
  movimiento guarda; el último valor es el que persiste. No hay pérdida de datos.
- ¿El volumen puede llegar a cero (silencio total)? → Sí. El slider puede ir
  a 0, silenciando completamente música o SFX según corresponda.

---

## Requirements

### Functional Requirements

- **FR-SET-001**: La pantalla de opciones DEBE mostrar dos sliders: uno para
  "Música" y otro para "SFX".
- **FR-SET-002**: Mover cualquier slider DEBE cambiar el volumen correspondiente
  en tiempo real, mientras se arrastra.
- **FR-SET-003**: Cada cambio de slider DEBE guardarse automáticamente — sin
  botón "Aplicar".
- **FR-SET-004**: Al entrar a opciones, los sliders DEBEN cargarse con los
  valores de la última sesión. Si no hay datos guardados, DEBEN estar al máximo.
- **FR-SET-005**: El audio DEBE sonar con los volúmenes guardados desde el
  momento en que se cargan los sliders — no después.
- **FR-SET-006**: DEBE existir un botón "Volver" que regrese a la pantalla de
  origen (menú principal o panel de pausa, según desde dónde se accedió).
- **FR-SET-007**: Desde el menú de pausa, las opciones DEBEN mostrarse como
  panel embebido — sin cambio de escena y sin fundido.

### Key Entities

- **Slider de Música**: Controla el volumen del bus de música (0% a 100%).
- **Slider de SFX**: Controla el volumen del bus de efectos de sonido (0% a 100%).
- **Archivo de configuración**: Persiste los valores de los sliders entre sesiones.
  Ubicado en el directorio de datos de usuario del sistema operativo.
- **Botón Volver**: Regresa a la pantalla de origen (menú principal o pausa).

---

## Success Criteria

### Measurable Outcomes

- **SC-SET-001**: Los sliders muestran los valores guardados inmediatamente al
  entrar a opciones — sin valores incorrectos visibles ni siquiera por un frame.
- **SC-SET-002**: Un cambio en el slider de música no afecta el slider ni el
  volumen de SFX, y viceversa.
- **SC-SET-003**: Después de cerrar y reabrir el juego, los volúmenes configurados
  son exactamente los mismos que al cerrar.
- **SC-SET-004**: El botón Volver lleva siempre a la pantalla correcta según
  el origen de navegación.
