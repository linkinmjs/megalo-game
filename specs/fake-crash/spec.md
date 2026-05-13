# Feature Specification: Fake Crash — Pantalla azul de "fin de juego"

**Created**: 2026-02-24

## Contexto

El juego no tiene un "Game Over" real. Al terminar el videoclip, en lugar de
volver al menú o mostrar un cartel, el juego **simula un crash del sistema
operativo**: la pantalla glitchea violentamente, suena un corte de sistema y
aparece una pantalla azul (estilo BSOD de Windows) con el error
`GAME_OVER_NOT_FOUND`.

La broma es que el juego "no sabe cómo terminar" — el Game Over no existe en
el código, así que crashea buscándolo.

El final puede activarse de dos maneras:
- **Automáticamente**, cuando la canción del juego termina.
- **Manualmente**, cuando el operador (director) activa la secuencia con una
  tecla dedicada — para usarlo en cualquier momento durante la grabación.

---

## User Scenarios & Testing

### User Story 1 — Secuencia de glitch previa al crash (Priority: P1)

Antes de que aparezca la pantalla azul, el juego "se rompe" visualmente: la
imagen se distorsiona de forma extrema durante aproximadamente un segundo, como
si el software estuviera fallando. El efecto es abrupto y caótico.

**Why this priority**: El glitch previo es lo que convierte el corte en un
evento dramático. Sin él, la transición al BSOD se siente abrupta y barata.

**Independent Test**: Activar el final (manual o automático) y verificar que
antes de la pantalla azul hay un momento de distorsión visual intensa.

**Acceptance Scenarios**:

1. **Scenario**: Glitch al activar la secuencia de fin
   - **Given** el juego está corriendo normalmente
   - **When** el operador activa el final manualmente, o la canción termina
   - **Then** la imagen se distorsiona violentamente (glitch extremo, shaders
     al máximo) durante ~1 segundo
   - **Then** el glitch termina con un corte seco — no hay fundido

2. **Scenario**: Sonido de corte de sistema durante el glitch
   - **Given** la secuencia de crash se activó
   - **When** comienza el glitch visual
   - **Then** suena un audio de corte grave (estilo apagado abrupto de sistema),
     simultáneo o muy cercano al inicio del glitch
   - **Then** la música del juego se detiene por completo en ese momento

---

### User Story 2 — Pantalla azul (BSOD) con mensaje de error (Priority: P1)

Tras el glitch, la pantalla se vuelve completamente azul y muestra un mensaje
de error detallado estilo BSOD de Windows. El texto usa lenguaje técnico falso
pero verosímil, con `GAME_OVER_NOT_FOUND` como stop code principal.

**Why this priority**: Es el payoff visual del gag. El texto específico y los
detalles técnicos son lo que lo hacen convincente.

**Independent Test**: Dejar que la secuencia llegue al BSOD y verificar que
toda la pantalla es azul con el texto completo legible en fuente monoespaciada.

**Acceptance Scenarios**:

1. **Scenario**: Aparición inmediata del BSOD tras el glitch
   - **Given** la secuencia de glitch terminó
   - **When** el corte seco ocurre
   - **Then** la pantalla completa se vuelve azul instantáneamente (sin fundido)
   - **Then** el gameplay y todos los efectos visuales desaparecen bajo el BSOD

2. **Scenario**: Contenido del BSOD visible y legible
   - **Given** la pantalla azul está activa
   - **When** se observa el texto en pantalla
   - **Then** se ven todos los elementos del mensaje, en este orden:
     ```
     :(

     Your game ran into a problem
     and needs to restart.

     0% complete

     For more information about this issue
     and possible fixes, visit:
     https://www.not-os.com/stopcode

     If you call a support person, give
     them this info:
     Stop code: GAME_OVER_NOT_FOUND
     Failing module: GameOver.dll
     Exception: ACCESS_VIOLATION (0xC0000005)
     Address: 0xFFFF0IS0DEAD
     ```
   - **Then** el texto está en fuente monoespaciada, color blanco sobre azul

3. **Scenario**: BSOD permanece estático salvo el botón de reset
   - **Given** la pantalla azul apareció
   - **When** pasa cualquier cantidad de tiempo
   - **Then** la pantalla permanece completamente estática — sin animaciones,
     sin porcentaje que avance, sin ningún cambio
   - **Then** el juego no responde a ninguna tecla del jugador ni del director,
     excepto la interacción con el botón de reinicio

---

### User Story 3 — Botón de reinicio en el BSOD (Priority: P2)

Dentro de la pantalla azul hay un botón visible que permite al jugador volver
al menú principal. Está integrado estéticamente en el BSOD — no rompe la
ilusión del crash, sino que la completa: el sistema "ofrece reiniciar".

**Why this priority**: Sin un escape, el único modo de salir del juego es
cerrarlo manualmente. El botón de reinicio permite repetir la experiencia sin
cerrar la ventana, clave para múltiples tomas en el videoclip.

**Independent Test**: Con el BSOD activo, hacer click en el botón de reinicio y
verificar que el juego vuelve al menú principal.

**Acceptance Scenarios**:

1. **Scenario**: Botón de reinicio visible en el BSOD
   - **Given** la pantalla azul está activa
   - **When** se observa la parte inferior de la pantalla
   - **Then** hay un botón claramente visible con la etiqueta `[ Restart ]`
     (o similar), integrado al estilo visual del BSOD

2. **Scenario**: El botón lleva al menú principal
   - **Given** el BSOD está activo y el botón de reinicio es visible
   - **When** el jugador hace click en el botón
   - **Then** el juego vuelve al menú principal con una transición (fade a negro)
   - **Then** el estado de crash se resetea completamente — el juego puede
     iniciarse y terminarse nuevamente desde cero

3. **Scenario**: Nada más responde en el BSOD
   - **Given** el BSOD está activo
   - **When** el jugador presiona cualquier tecla del teclado o hace click
     en cualquier parte que no sea el botón
   - **Then** no ocurre ninguna acción — solo el botón de reinicio es funcional

---

### User Story 4 — Activación automática al terminar la canción (Priority: P2)

Cuando la canción llega a su fin natural, el juego inicia la secuencia de crash
automáticamente, sin intervención del operador. Esto sincroniza el final del
videoclip con el final de la música.

**Why this priority**: Es el flujo principal del videoclip. El trigger manual
existe como fallback, pero el cierre "correcto" está sincronizado con la canción.

**Independent Test**: Dejar correr el juego sin intervención hasta que la
canción termine y verificar que la secuencia de crash arranca sola.

**Acceptance Scenarios**:

1. **Scenario**: Secuencia arranca al detectar fin de canción
   - **Given** el juego está corriendo y la canción se está reproduciendo
   - **When** la canción llega a su último frame de audio
   - **Then** la secuencia de glitch inicia automáticamente (sin input del operador)

2. **Scenario**: No se dispara dos veces
   - **Given** la secuencia de crash ya fue activada (manual o automática)
   - **When** el operador presiona la tecla de crash nuevamente, o la canción
     terminaría de nuevo
   - **Then** la secuencia no se reinicia ni interrumpe — la pantalla azul
     permanece estática

---

### User Story 5 — Activación manual por el operador (Priority: P2)

El operador puede disparar la secuencia de crash en cualquier momento durante
la grabación, usando una tecla del sistema de director. Permite controlar el
timing de cierre independientemente de cuándo termina la canción.

**Why this priority**: Da control total al director durante la grabación. Si
necesita cortar antes o después de que la canción termine, puede hacerlo.

**Independent Test**: Durante el gameplay, activar la tecla de crash del director
y verificar que la secuencia comienza independientemente del estado de la canción.

**Acceptance Scenarios**:

1. **Scenario**: Crash manual en cualquier momento
   - **Given** el juego está corriendo (en cualquier estado — con o sin efectos
     del director activos)
   - **When** el operador activa la tecla de crash del director
   - **Then** la secuencia de glitch inicia inmediatamente

2. **Scenario**: El crash manual no interfiere con los efectos activos
   - **Given** hay efectos del director activos (nube, aspiradora, pájaros, etc.)
   - **When** el operador activa el crash
   - **Then** el glitch ocurre sobre el estado actual de la pantalla (con todos
     los efectos visibles), haciendo el crash más caótico y visualmente rico

---

### Edge Cases

- ¿Qué pasa si la canción no tiene archivo de audio cargado? → La secuencia
  de crash no se dispara automáticamente (no hay canción que "terminar"). Solo
  el trigger manual funciona.
- ¿Qué pasa si el juego está pausado cuando termina la canción? → La secuencia
  de crash se activa igual — el BSOD tiene prioridad sobre el estado de pausa.
- ¿Qué pasa si el operador activa el crash mientras ocurre una transición de
  fondo (F1)? → El crash interrumpe la transición; el glitch ocurre sobre el
  estado visual actual.
- ¿Se puede "salir" del BSOD? → Sí, pero solo mediante el botón `[ Restart ]`
  visible en pantalla. Ninguna tecla del teclado produce efecto.
- ¿Qué pasa si el jugador hace click fuera del botón en el BSOD? → Nada.
  Solo el botón de reinicio es interactivo.

---

## Requirements

### Functional Requirements

- **FR-CRASH-001**: La secuencia de crash DEBE iniciarse automáticamente cuando
  la canción del juego finaliza.
- **FR-CRASH-002**: La secuencia de crash DEBE poder activarse manualmente
  mediante una tecla del director en cualquier momento.
- **FR-CRASH-003**: Al iniciarse la secuencia, DEBE reproducirse un sonido de
  corte de sistema (grave, brusco) y la música DEBE detenerse en ese instante.
- **FR-CRASH-004**: La imagen DEBE distorsionarse con glitch visual extremo
  (~1 segundo) antes del corte a la pantalla azul.
- **FR-CRASH-005**: El glitch DEBE terminar con un corte seco — sin fundido.
- **FR-CRASH-006**: La pantalla azul DEBE cubrir toda la pantalla de forma
  instantánea, ocultando completamente el gameplay.
- **FR-CRASH-007**: El BSOD DEBE mostrar el siguiente contenido exacto en fuente
  monoespaciada blanca sobre fondo azul:
  - Cara triste: `:(`
  - Mensaje: `Your game ran into a problem and needs to restart.`
  - Porcentaje: `0% complete` (estático, no avanza)
  - URL: `https://www.not-os.com/stopcode`
  - Stop code: `GAME_OVER_NOT_FOUND`
  - Módulo: `Failing module: GameOver.dll`
  - Excepción: `Exception: ACCESS_VIOLATION (0xC0000005)`
  - Dirección: `Address: 0xFFFF0IS0DEAD`
- **FR-CRASH-008**: Una vez activa la pantalla azul, el juego NO DEBE responder
  a ninguna tecla de gameplay ni del director.
- **FR-CRASH-009**: La secuencia NO DEBE poder activarse dos veces (una vez
  iniciada, el trigger manual y automático quedan deshabilitados).
- **FR-CRASH-010**: El BSOD DEBE mostrar un botón `[ Restart ]` (u etiqueta
  equivalente que encaje en la estética del BSOD) en la parte inferior de la
  pantalla.
- **FR-CRASH-011**: Al hacer click en el botón de reinicio, el juego DEBE
  volver al menú principal con un fade a negro y resetear completamente el
  estado de crash (permitiendo iniciar una nueva partida).
- **FR-CRASH-012**: Ninguna interacción fuera del botón de reinicio (teclas,
  clicks en otras zonas) DEBE producir efecto mientras el BSOD está activo.

### Key Entities

- **Secuencia de crash**: El conjunto completo (audio + glitch + BSOD). Se
  activa una sola vez por sesión.
- **Glitch pre-crash**: Distorsión visual extrema de ~1 segundo que precede al
  BSOD. Usa los shaders existentes del director al máximo de intensidad.
- **Sonido de corte**: Audio de apagado abrupto de sistema. Reemplaza a la
  música en el momento del crash.
- **Pantalla BSOD**: Overlay que cubre toda la pantalla. Azul sólido, texto
  monoespaciado. Estática salvo por el botón de reinicio.
- **Botón de reinicio**: Único elemento interactivo del BSOD. Estilizado para
  encajar en la estética del BSOD. Al presionarlo, lleva al menú principal.

---

## Success Criteria

### Measurable Outcomes

- **SC-CRASH-001**: Al terminar la canción, la secuencia de crash inicia en
  menos de 0.5s desde el último frame de audio.
- **SC-CRASH-002**: El glitch visual dura entre 0.8 y 1.2 segundos — suficiente
  para ser dramático, no tanto como para ser tedioso.
- **SC-CRASH-003**: La pantalla azul cubre el 100% de la pantalla — ningún
  elemento del juego es visible detrás.
- **SC-CRASH-004**: El texto del BSOD es legible al 100% en la resolución base
  (1280×720) — sin texto cortado ni fuera de pantalla.
- **SC-CRASH-005**: Una vez en BSOD, ninguna tecla (gameplay o director) produce
  ningún efecto visual ni sonoro — solo el botón `[ Restart ]` es interactivo.
- **SC-CRASH-006**: Al presionar `[ Restart ]`, el juego vuelve al menú
  principal en ≤ 1 segundo (incluyendo el fade a negro).
