# Feature Specification: Megalo — Juego Globo Aerostático para Videoclip

**Created**: 2026-02-21

## User Scenarios & Testing *(mandatory)*

<!--
  Las user stories están ordenadas por prioridad.
  Cada una es independientemente verificable y entrega valor por sí sola.
-->

### User Story 1 — Control del globo aerostático (Priority: P1)

El jugador controla un globo aerostático que flota en un mundo con scroll lateral automático. Puede encender el mechero para subir y apagarlo para descender por gravedad. También puede moverse levemente de izquierda a derecha dentro de la pantalla.

**Why this priority**: Es el núcleo jugable del juego. Sin este control nada lo demás tiene sentido.

**Independent Test**: Abrir la escena del juego, presionar las teclas de control y verificar que el globo sube, baja y se mueve lateralmente de forma fluida y satisfactoria.

**Acceptance Scenarios**:

1. **Scenario**: Mecánica del mechero — subida
   - **Given** el juego está corriendo y el globo está en el centro de la pantalla
   - **When** el jugador mantiene presionada la tecla Espacio (o W o Flecha Arriba)
   - **Then** el mechero se activa visualmente y el globo asciende de forma gradual (no instantánea)

2. **Scenario**: Mecánica del mechero — bajada por gravedad
   - **Given** el mechero está encendido y el globo está subiendo
   - **When** el jugador suelta la tecla
   - **Then** el mechero se apaga y el globo desciende gradualmente por efecto de la gravedad

3. **Scenario**: Movimiento lateral
   - **Given** el juego está corriendo
   - **When** el jugador presiona A o Flecha Izquierda
   - **Then** el globo se desplaza hacia la izquierda con suavidad
   - **When** el jugador presiona D o Flecha Derecha
   - **Then** el globo se desplaza hacia la derecha con suavidad

4. **Scenario**: Límites de pantalla
   - **Given** el globo está cerca del borde superior/inferior/lateral
   - **When** el jugador intenta moverlo más allá del límite
   - **Then** el globo no puede salir de los límites visibles de la pantalla

5. **Scenario**: Inflado del globo con el quemador activo
   - **Given** el quemador está apagado y el globo tiene su tamaño normal
   - **When** el jugador activa el quemador y lo mantiene presionado
   - **Then** el sprite del globo crece suavemente hasta un tamaño máximo levemente mayor (no más del 8% del tamaño original), transmitiendo la sensación de que el globo se está inflando con el calor
   - **When** el jugador suelta el quemador
   - **Then** el sprite del globo vuelve suavemente a su tamaño original
   - **Then** la calavera y el collision shape NO cambian de tamaño — solo el sprite visual del globo se escala

6. **Scenario**: Movimiento relativo calavera–globo (comportamiento pendular)
   - **Given** el globo está en movimiento lateral
   - **When** el jugador mueve el globo hacia la derecha
   - **Then** la calavera se desplaza levemente hacia la izquierda respecto al globo (arrastre), como si colgara de una cuerda, y luego vuelve al centro suavemente cuando el movimiento cesa
   - **Then** el desplazamiento lateral de la calavera es visiblemente menor que el del globo — la calavera no "baila" ni oscila de un lado al otro; simplemente muestra un retraso amortiguado
   - **Then** cuando el globo sube o baja rápido, la calavera tiene un leve desplazamiento vertical complementario (sube un poco al frenar la subida, baja un poco al frenar la bajada) pero menos pronunciado que el lateral

---

### User Story 2 — Obstáculos / "recuerdos" (Priority: P2)

Objetos abstractos que representan recuerdos (cenicero, frasco, etc.) aparecen moviéndose horizontalmente por la pantalla. Al contacto con el globo lo empujan levemente, generando "juicing" visual sin matarlo.

**Why this priority**: Aporta dinamismo y variedad visual al videoclip. Sin obstáculos el juego es estático.

**Independent Test**: Forzar el spawn de un obstáculo manualmente, verificar que cruza la pantalla y que al tocar el globo lo desplaza sin destruirlo.

**Acceptance Scenarios**:

1. **Scenario**: Aparición y movimiento de obstáculo
   - **Given** el juego está corriendo
   - **When** el spawner genera un cenicero
   - **Then** aparece desde el borde izquierdo y se desplaza hacia la derecha hasta salir de pantalla

2. **Scenario**: Obstáculo desde la derecha
   - **Given** el juego está corriendo
   - **When** el spawner genera un frasco
   - **Then** aparece desde el borde derecho y se desplaza hacia la izquierda hasta salir de pantalla

3. **Scenario**: Colisión sin muerte
   - **Given** el globo y un obstáculo están en trayectoria de colisión
   - **When** se produce el contacto
   - **Then** el globo recibe un impulso (knockback) en la dirección opuesta al obstáculo, pero no muere ni pierde vidas

4. **Scenario**: Feedback visual en colisión
   - **Given** se produce una colisión
   - **When** el globo recibe el knockback o genera algún efecto en la pantalla
   - **Then** se reproduce una animación de squish/stretch en el globo

---

### User Story 3 — Parallax background y atmósfera visual (Priority: P2)

El fondo tiene múltiples capas de parallax con diferentes velocidades de scroll, creando sensación de profundidad. Incluye cielo, nubes y elementos cercanos. El player se encuentra en la segunda capa del parallax, es decir que hay un parallax más antes del player.

**Why this priority**: El aspecto visual es fundamental para el videoclip. El parallax le da vida al mundo.

**Independent Test**: Ejecutar el juego y verificar que las capas del fondo se mueven a distintas velocidades generando efecto de profundidad.

**Acceptance Scenarios**:

1. **Scenario**: Scroll automático del fondo
   - **Given** el juego está corriendo
   - **When** no hay ninguna acción del jugador
   - **Then** el fondo hace scroll horizontal continuo de derecha a izquierda

2. **Scenario**: Efecto parallax con profundidad
   - **Given** el juego está corriendo con múltiples capas visibles
   - **When** se observa el fondo
   - **Then** las capas más lejanas se mueven más lento que las más cercanas, generando sensación de profundidad 3D

3. **Scenario**: Cambio de fondo con tecla F1
   - **Given** hay múltiples fondos cargados
   - **When** el director presiona F1
   - **Then** el fondo transiciona suavemente (fade/cross-fade) al siguiente fondo disponible

---

### User Story 4 — Sistema de Director con eventos en tiempo real (Priority: P3)

El operador puede triggerear eventos visuales y atmosféricos durante la grabación del videoclip usando teclas de función. Los eventos modifican el mundo en tiempo real: lluvia, viento, bandada de pájaros, etc.

**Why this priority**: Es la herramienta creativa principal para sincronizar el juego con la música durante la grabación.

**Independent Test**: Durante la ejecución, presionar cada tecla de función y verificar que el evento correspondiente se activa/desactiva correctamente.

**Acceptance Scenarios**:

1. **Scenario**: Toggle nube de lluvia (F2)
   - **Given** el juego está corriendo
   - **When** el director presiona F2
   - **Then** aparece una nube que comienza a llover siguiendo la player de manera torpe y el efecto de lluvia molesta levemente al globo (empuje hacia abajo)
   - **When** el director presiona F2 nuevamente
   - **Then** la nube y la lluvia desaparecen gradualmente

2. **Scenario**: Toggle viento (F3)
   - **Given** el juego está corriendo
   - **When** el director presiona F3
   - **Then** un efecto de viento empuja al globo lateralmente y se visualizan partículas de viento en pantalla
   - **When** el director presiona F3 nuevamente
   - **Then** el viento cesa gradualmente

3. **Scenario**: Toggle bandada de pájaros (F4)
   - **Given** el juego está corriendo
   - **When** el director presiona F4
   - **Then** una bandada de pájaros cruza la pantalla como capa de parallax en movimiento
   - **When** el director presiona F4 nuevamente
   - **Then** los pájaros desaparecen

4. **Scenario**: Spawn manual de obstáculo (F5)
   - **Given** el juego está corriendo
   - **When** el director presiona F5
   - **Then** aparece inmediatamente un obstáculo aleatorio en pantalla

---

### User Story 5 — Audio sincronizado (Priority: P3)

La canción suena durante el juego. El director controla manualmente los eventos para sincronizarlos con la música durante la grabación del videoclip.

**Why this priority**: La sincronía musical es el propósito final del proyecto, pero depende de tener los sistemas anteriores funcionando.

**Independent Test**: Colocar un archivo de audio en assets/audio/, ejecutar el juego y verificar que la canción comienza a sonar.

**Acceptance Scenarios**:

1. **Scenario**: Reproducción automática al inicio
   - **Given** hay un archivo de audio en assets/audio/
   - **When** el juego comienza
   - **Then** la canción empieza a reproducirse automáticamente

2. **Scenario**: El juego dura aproximadamente la duración de la canción
   - **Given** la canción dura ~2 minutos
   - **When** el juego está en ejecución
   - **Then** el juego se mantiene activo durante toda la duración de la canción sin pantallas de game over ni interrupciones

---

### Edge Cases

- ¿Qué pasa si el globo llega al borde superior e intenta seguir subiendo? → Puede subir un poco más y desaparecer de la pantalla. Pero no subir infinitamente
- ¿Qué pasa si varios obstáculos colisionan con el globo al mismo tiempo? → Cada uno aplica su knockback independientemente; el globo puede recibir múltiples impulsos pero nunca sale de pantalla.
- ¿Qué pasa si el director presiona F1 pero solo hay un fondo cargado? → El fondo se queda igual, sin error.
- ¿Qué pasa si no hay archivo de audio en assets/audio/? → El juego funciona normalmente sin sonido (no crashea).
- ¿Qué pasa si la nube de lluvia ya está activa y se presiona F2 de nuevo antes de que termine de aparecer? → Se inicia el proceso de desaparición inmediatamente.

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: El sistema DEBE renderizar un globo aerostático controlable por el jugador en pantalla completa (PC).
- **FR-002**: El globo DEBE responder a la tecla de mechero (Espacio/W/↑) subiendo gradualmente con aceleración.
- **FR-003**: El globo DEBE descender por gravedad cuando no se presiona la tecla de mechero.
- **FR-004**: El globo DEBE moverse lateralmente con las teclas A/D o flechas izquierda/derecha.
- **FR-005**: El globo NO DEBE poder salir de los límites visibles de la pantalla por los bordes laterales, inferior ni superior de forma indefinida. El borde superior permite una salida leve (el globo puede desaparecer parcialmente) antes de frenar.
- **FR-006**: El sistema DEBE generar obstáculos ("recuerdos") de forma automática durante el juego.
- **FR-007**: Los obstáculos DEBEN moverse horizontalmente y desaparecer al salir de pantalla.
- **FR-008**: Los obstáculos DEBEN aplicar un impulso (knockback) al globo al colisionar, sin eliminarlo.
- **FR-009**: El juego DEBE mostrar un fondo con scroll lateral continuo y efecto parallax multicapa.
- **FR-010**: El sistema DEBE soportar múltiples fondos intercambiables en tiempo real mediante la tecla F1.
- **FR-011**: El cambio de fondo DEBE realizarse con una transición suave (fade).
- **FR-012**: El sistema de Director DEBE activar/desactivar una nube de lluvia con la tecla F2. La nube DEBE seguir al player de manera torpe (con retraso e inercia) mientras esté activa.
- **FR-013**: El sistema de Director DEBE activar/desactivar un efecto de viento con la tecla F3.
- **FR-014**: El sistema de Director DEBE activar/desactivar una bandada de pájaros con la tecla F4.
- **FR-015**: El sistema de Director DEBE permitir el spawn manual de un obstáculo con la tecla F5.
- **FR-016**: Los controles del Director NO DEBEN ser visibles en pantalla durante la grabación.
- **FR-017**: El juego DEBE reproducir automáticamente el archivo de audio al iniciar.
- **FR-018**: El juego NO DEBE tener sistema de puntuación, vidas ni game over.
- **FR-019**: El juego DEBE aplicar un efecto visual de tipo VHS (scanlines, aberración cromática) sobre toda la pantalla.
- **FR-020**: El estilo visual DEBE combinar pixel art, ilustraciones abstractas y efectos ligeramente psicodélicos.

### Key Entities

- **Globo (Player)**: El personaje controlado por el jugador. Está compuesto por **dos sprites independientes**: el globo aerostático en la parte superior y una calavera steampunk con parlante en la boca colgando debajo. La calavera se conecta al globo como un péndulo amortiguado — sigue el movimiento del globo con retraso y un sway lateral suave pero limitado (ver detalles en US1 Scenario 5). Tiene física (gravedad, mechero), puede recibir knockback y tiene animaciones de squish/stretch.
- **Obstáculo (Obstacle)**: Objeto que atraviesa la pantalla horizontalmente. Tiene dirección, velocidad y fuerza de knockback. Subtipos: Cenicero, Frasco, (extensible).
- **Fondo (Background)**: Recurso visual compuesto por múltiples capas parallax. Intercambiable en tiempo real.
- **Evento de Director (DirectorEvent)**: Acción triggereada por el operador vía tecla. Activa/desactiva sistemas del juego (lluvia, viento, pájaros).

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: El globo responde a las teclas de control en menos de 1 frame (60fps), con movimiento fluido y sin lag perceptible.
- **SC-002**: El juego se mantiene en ejecución durante al menos 2 minutos sin crashes, freezes ni errores de consola.
- **SC-003**: El director puede triggerear todos los eventos definidos (F1–F5) en tiempo real sin interrumpir la ejecución del juego.
- **SC-004**: Los eventos del Director se activan/desactivan en menos de 0.5 segundos desde la pulsación de tecla.
- **SC-005**: La transición entre fondos se completa en 1-2 segundos con una animación suave y sin cortes bruscos.
- **SC-006**: El efecto VHS es visible en toda la pantalla en todo momento durante la ejecución.
- **SC-007**: El juego puede ser grabado en pantalla como videoclip durante la reproducción completa de la canción sin modificar el código entre tomas.
