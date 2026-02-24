# Feature Specification: Director — Control de Shaders de Pantalla

**Created**: 2026-02-23

---

## Contexto

El juego aplica actualmente un único shader VHS fijo sobre la pantalla completa.
Esta feature le da al director control en tiempo real sobre **tres shaders de pantalla**:
puede navegar entre ellos (F6/F8) y potenciar el efecto activo mientras mantiene F7
presionado; al soltar F7, la pantalla vuelve gradualmente a su estado base.

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Navegación entre shaders (Priority: P1)

El director puede cambiar el efecto visual de pantalla completa entre tres opciones
durante la grabación del videoclip, sin interrumpir el juego.

**Why this priority**: Es la capacidad base del sistema. Sin navegación no hay elección
de efecto.

**Independent Test**: Con el juego corriendo, presionar F8 y verificar que el efecto
visual de pantalla cambia al siguiente. Presionar F6 para volver al anterior. Verificar
que F8 en el último efecto no hace nada, y F6 en el primero no hace nada.

**Acceptance Scenarios**:

1. **Scenario**: F8 avanza al shader siguiente
   - **Given** el juego está corriendo con el shader activo en posición 1 o 2
   - **When** el director presiona F8
   - **Then** el efecto visual de pantalla cambia inmediatamente al siguiente shader de la lista

2. **Scenario**: F6 retrocede al shader anterior
   - **Given** el juego está corriendo con el shader activo en posición 2 o 3
   - **When** el director presiona F6
   - **Then** el efecto visual de pantalla cambia inmediatamente al shader anterior de la lista

3. **Scenario**: F8 en el último shader no hace nada
   - **Given** el shader activo es el último de la lista (posición 3, pixelado)
   - **When** el director presiona F8
   - **Then** el efecto no cambia (la navegación es lineal, no circular)

4. **Scenario**: F6 en el primer shader no hace nada
   - **Given** el shader activo es el primero de la lista (posición 1, VHS)
   - **When** el director presiona F6
   - **Then** el efecto no cambia

5. **Scenario**: Al cambiar de shader, el efecto empieza en su valor base
   - **Given** el director navega a un shader diferente (con F6 o F8)
   - **When** el nuevo shader aparece en pantalla
   - **Then** el efecto se muestra con su intensidad por defecto, no exagerado

---

### User Story 2 — Potenciado temporal con F7 (Priority: P1)

Mientras el director mantiene presionado F7, el shader activo se intensifica
gradualmente hasta alcanzar su máximo exagerado. Al soltar, la intensidad baja
gradualmente de vuelta al valor base del shader.

**Why this priority**: Es la herramienta expresiva principal — permite sincronizar picos
visuales con la música durante la grabación.

**Independent Test**: Con cualquier shader activo, mantener F7 presionado durante ~2
segundos y verificar que el efecto se vuelve notablemente más exagerado de forma
gradual. Soltar y verificar que el efecto vuelve gradualmente a su estado base.

**Acceptance Scenarios**:

1. **Scenario**: Mantener F7 intensifica el shader gradualmente
   - **Given** el juego está corriendo con cualquier shader activo en su valor base
   - **When** el director mantiene F7 presionado
   - **Then** la intensidad del efecto visual aumenta gradualmente hasta alcanzar el
     máximo exagerado del shader (no cambia de golpe)

2. **Scenario**: Soltar F7 devuelve el efecto al valor base
   - **Given** el director tenía F7 presionado y el shader está potenciado
   - **When** el director suelta F7
   - **Then** la intensidad disminuye gradualmente de vuelta al valor base del shader

3. **Scenario**: El retorno es gradual, no instantáneo
   - **Given** el shader estaba a máxima intensidad
   - **When** el director suelta F7
   - **Then** el efecto no corta abruptamente; la pantalla vuelve suavemente a su
     estado base en un tiempo visible (≥ 0.5s)

4. **Scenario**: F7 potencia el shader activo, no uno fijo
   - **Given** el director cambió al shader de aberración cromática
   - **When** mantiene F7 presionado
   - **Then** la aberración cromática (separación de canales RGB) se exagera,
     no el VHS

---

### User Story 3 — Tres shaders disponibles (Priority: P1)

La lista de shaders tiene tres efectos con identidades visuales distintas:
VHS, aberración cromática y pixelado.

**Why this priority**: Define el catálogo expresivo disponible para el director.

**Independent Test**: Navegar con F8 por los tres shaders y verificar que cada uno
tiene una identidad visual claramente diferente.

**Acceptance Scenarios**:

1. **Scenario**: Shader 1 — VHS
   - **Given** el shader activo es el primero de la lista
   - **When** se observa la pantalla
   - **Then** se ve el efecto VHS: jitter horizontal, aberración cromática sutil,
     ruido estático leve y ondulación de cinta
   - **When** el director potencia con F7
   - **Then** los glitches se vuelven más frecuentes e intensos, el jitter horizontal
     es exagerado y la aberración cromática aumenta notablemente

2. **Scenario**: Shader 2 — Aberración cromática
   - **Given** el shader activo es el segundo de la lista
   - **When** se observa la pantalla
   - **Then** los canales RGB de la imagen están levemente separados (efecto prisma sutil)
   - **When** el director potencia con F7
   - **Then** la separación de los canales RGB se exagera hasta producir un split de
     colores muy pronunciado (el rojo, verde y azul de la imagen se ven desplazados)

3. **Scenario**: Shader 3 — Pixelado / retro
   - **Given** el shader activo es el tercero de la lista
   - **When** se observa la pantalla
   - **Then** la imagen tiene un pixelado sutil que le da aspecto retro/8-bit
   - **When** el director potencia con F7
   - **Then** el tamaño de los píxeles aumenta considerablemente, haciendo la imagen
     muy baja resolución de forma exagerada

---

### User Story 4 — Toggle de shader (descanso visual) (Priority: P1)

El director puede apagar el shader completamente con la tecla 9 para brindar un
descanso visual entre segmentos del videoclip. Un segundo press lo reactiva,
restaurando el mismo shader que estaba activo.

**Why this priority**: Los shaders pueden resultar agotadores visualmente para el
espectador. El toggle es la herramienta de "respiro" esencial del director.

**Independent Test**: Con el juego corriendo y el shader VHS visible, presionar 9 y
verificar que la pantalla queda limpia (sin efecto). Presionar 9 nuevamente y verificar
que el shader vuelve exactamente como estaba.

**Acceptance Scenarios**:

1. **Scenario**: 9 apaga el shader activo
   - **Given** el juego está corriendo con cualquier shader visible
   - **When** el director presiona 9
   - **Then** el efecto de pantalla desaparece completamente — la imagen se ve limpia
     como si no hubiera ningún shader

2. **Scenario**: 9 reactiva el shader anterior
   - **Given** el shader está apagado (pantalla limpia)
   - **When** el director presiona 9 nuevamente
   - **Then** el mismo shader que estaba activo antes del apagado vuelve a verse,
     en su estado base (sin potenciado)

3. **Scenario**: El índice activo se preserva al apagar y reactivas
   - **Given** el director navegó al shader de aberración cromática y luego apagó con 9
   - **When** presiona 9 para reactivar
   - **Then** vuelve la aberración cromática — no el VHS ni el pixelado

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-SHD-01**: El juego DEBE mantener una lista ordenada de 3 shaders de pantalla:
  1. VHS, 2. Aberración cromática, 3. Pixelado.
- **FR-SHD-02**: 8 DEBE avanzar al shader siguiente en la lista; en el último, no hace nada.
- **FR-SHD-03**: 6 DEBE retroceder al shader anterior en la lista; en el primero, no hace nada.
- **FR-SHD-04**: Al cambiar de shader, el nuevo efecto DEBE aparecer en su valor base
  (no potenciado).
- **FR-SHD-05**: Mientras 7 esté presionado, la intensidad del shader activo DEBE
  aumentar gradualmente desde el valor base hasta el máximo exagerado.
- **FR-SHD-06**: Al soltar 7, la intensidad DEBE bajar gradualmente de vuelta al valor
  base (no cortar abruptamente).
- **FR-SHD-07**: Al cambiar de shader (6/8), el nivel de potenciado DEBE resetearse
  al valor base del nuevo shader, independientemente de si 7 estaba presionado.
- **FR-SHD-08**: El shader activo al inicio del juego DEBE ser el VHS (posición 1).
- **FR-SHD-09**: El efecto del shader DEBE aplicarse sobre la pantalla completa
  (incluyendo UI, fondos y player).
- **FR-SHD-10**: La tecla 9 DEBE alternar el estado del shader entre activo e inactivo
  (toggle).
- **FR-SHD-11**: Al desactivar el shader con 9, la pantalla DEBE mostrarse completamente
  limpia (sin ningún efecto de postproceso visible).
- **FR-SHD-12**: Al reactivar el shader con 9, DEBE restaurarse el mismo shader que
  estaba activo antes del apagado, en su valor base (boost = 0).

### Parámetros potenciables por shader

| Shader             | Parámetro base (valor por defecto)      | Parámetro máximo (potenciado)              |
|--------------------|-----------------------------------------|--------------------------------------------|
| VHS                | Glitches ocasionales, jitter sutil      | Glitches frecuentes, jitter exagerado, aberración fuerte |
| Aberración cromática | Split RGB apenas perceptible          | Split RGB extremo, canales muy separados   |
| Pixelado           | Pixelado sutil (look retro)             | Píxeles grandes, muy baja resolución       |

### Key Entities

- **ShaderDirector**: Gestiona la lista de shaders, el índice activo, el nivel de
  potenciado y el estado on/off. Recibe las teclas 6, 7, 8 y 9.
- **Lista de shaders** (array ordenado): Los 3 efectos disponibles en su orden fijo.
- **Índice activo** (int 0–2): Apunta al shader seleccionado (se preserva aunque el
  shader esté apagado).
- **Estado activo** (bool): `true` = shader visible, `false` = pantalla limpia.
- **Nivel de potenciado** (float 0.0–1.0): Controlado por si 7 está presionado
  (sube gradualmente) o suelto (baja gradualmente). Se resetea a 0.0 al cambiar
  de shader o al reactivar.
- **Pantalla de efectos (CanvasLayer)**: Nodo sobre el que se aplica el shader activo.
  Se oculta completamente cuando el shader está apagado.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-SHD-01**: El cambio de shader (6/8) se aplica en ≤ 1 frame — sin transición,
  la pantalla cambia inmediatamente al nuevo efecto.
- **SC-SHD-02**: El potenciado (7 presionado) alcanza el máximo exagerado en un tiempo
  perceptible (≈ 1–2 segundos de rampa), no de forma instantánea.
- **SC-SHD-03**: Al soltar 7, el efecto vuelve al valor base en ≥ 0.5 segundos.
- **SC-SHD-04**: Los 3 shaders tienen identidades visuales claramente distinguibles
  entre sí, verificables a simple vista al navegar con 8.
- **SC-SHD-05**: El sistema no produce drops de framerate perceptibles ni stutters
  durante la navegación entre shaders o el potenciado.
- **SC-SHD-06**: El toggle con 9 es instantáneo (≤ 1 frame) y consistente — la pantalla
  queda completamente limpia al apagar, sin artefactos residuales del shader.

---

## Edge Cases

- ¿Qué pasa si el director cambia de shader mientras tiene 7 presionado? → El nuevo
  shader aparece en su valor base; el potenciado reinicia desde 0.0 aunque 7 siga
  apretado (empieza a subir desde base).
- ¿Qué pasa si 7 se presiona con el shader apagado (9)? → El boost no tiene efecto
  visible; al reactivar con 9, el shader reaparece en su base (boost = 0).
- ¿Qué pasa si el director navega de shader (6/8) con el shader apagado? → El índice
  activo cambia internamente pero no se ve nada hasta que se reactive con 9.
- ¿Qué pasa si 8 y 6 se presionan simultáneamente? → Se ignoran ambos (sin cambio).
- ¿Qué pasa si se pausa el juego con un shader potenciado? → El shader se congela en
  ese nivel durante la pausa; al reanudar sigue desde donde estaba.
