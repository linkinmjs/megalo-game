# Feature Specification: Nueva animación de golpe / hurt (knockback)

**Created**: 2026-02-23

## Contexto

Esta feature **reemplaza** la animación de knockback actual del globo.

El comportamiento anterior (squish/stretch del tamaño del jugador al recibir un golpe)
queda **deprecated** y es reemplazado por un efecto de tres fases:

1. **Flash de color**: el globo (y calavera) se tiñe de rojo inmediatamente.
2. **Freeze de input**: el control del jugador se desactiva por ~0.3 segundos.
3. **Impulso**: el globo sale disparado en la dirección del knockback, con fuerza moderada.

Este cambio actualiza el **US2 Scenario 4** del spec principal (`specs/megalo-balloon/spec.md`).

---

## User Scenarios & Testing

### User Story 1 — Flash de color al recibir un golpe (Priority: P1)

Cuando un obstáculo golpea al globo, este se tiñe de rojo de forma inmediata y vuelve
gradualmente a su color normal. El efecto comunica "recibí daño" de forma clara e instantánea.

**Why this priority**: Es el feedback visual más importante de la colisión. Sin él las
colisiones se sienten inertes e invisibles.

**Independent Test**: Dejar que un obstáculo golpee al globo y observar que el color
del globo cambia a rojo y luego se recupera en ~0.4 segundos.

**Acceptance Scenarios**:

1. **Scenario**: Tinte rojo inmediato al golpe
   - **Given** el globo es golpeado por un obstáculo
   - **When** se produce la colisión
   - **Then** el globo (sprite del globo y calavera) se tiñe de rojo de forma inmediata
   - **Then** el tinte es fuerte y claramente perceptible (no sutil)

2. **Scenario**: Recuperación gradual al color normal
   - **Given** el globo fue golpeado y está mostrando el tinte rojo
   - **When** pasan ~0.4 segundos
   - **Then** el color vuelve gradualmente al normal mediante una transición suave
   - **Then** no hay ningún flash remanente al terminar

3. **Scenario**: Sin cambio de tamaño
   - **Given** el globo es golpeado por un obstáculo
   - **When** se produce la colisión y durante toda la animación
   - **Then** el globo NO cambia de tamaño; no hay squish ni stretch
   - **Then** el tamaño del globo y la calavera permanece igual antes, durante y después del golpe

---

### User Story 2 — Freeze de input tras el golpe (Priority: P1)

Cuando el globo recibe un golpe, el control del jugador (mechero y movimiento lateral) se
desactiva brevemente (~0.3 segundos), comunicando un estado de "aturdimiento" momentáneo.

**Why this priority**: El freeze es la consecuencia de gameplay del golpe. Da peso a la
colisión y la diferencia de simplemente tocar un objeto sin consecuencias.

**Independent Test**: Dejar que un obstáculo golpee al globo y tratar de usar los controles
inmediatamente después. Verificar que no responden por ~0.3 segundos.

**Acceptance Scenarios**:

1. **Scenario**: Input desactivado durante el freeze
   - **Given** el globo acaba de recibir un golpe
   - **When** el jugador presiona Espacio o una tecla de movimiento lateral durante el freeze
   - **Then** el globo no responde al input (no sube por el mechero, no se mueve lateralmente)
   - **Then** la física (gravedad, knockback) sigue activa — el globo se mueve por inercia

2. **Scenario**: Control recuperado pasado el freeze
   - **Given** han pasado ~0.3 segundos desde el golpe
   - **When** el jugador presiona cualquier tecla de control
   - **Then** el globo responde normalmente sin ningún estado residual

---

### User Story 3 — Impulso de salida controlado (Priority: P1)

El globo recibe un impulso de velocidad en la dirección del knockback. La fuerza es moderada:
suficiente para que el desplazamiento sea perceptible, pero sin llevar al globo hasta el borde
de pantalla ni desestabilizar el juego.

**Why this priority**: El impulso da "peso físico" a la colisión. Sin él el golpe se siente
inmaterial.

**Independent Test**: Dejar que un obstáculo golpee al globo y verificar que el globo se
desplaza notablemente en la dirección del rebote, pero sin salir de pantalla ni volar lejos.

**Acceptance Scenarios**:

1. **Scenario**: Impulso en dirección opuesta al obstáculo
   - **Given** un obstáculo golpea al globo desde la derecha
   - **When** se produce la colisión
   - **Then** el globo sale impulsado hacia la izquierda con velocidad perceptible
   - **Then** el globo frena gradualmente por la física normal (sin deslizamiento infinito)

2. **Scenario**: Impulso moderado — no llega al borde
   - **Given** el globo está en el centro de la pantalla y recibe un knockback
   - **When** el impulso se aplica
   - **Then** el globo se desplaza visiblemente pero no alcanza el borde de pantalla en
     condiciones normales (~150-200 px desde el punto de impacto es suficiente)

3. **Scenario**: Límites de pantalla activos durante knockback
   - **Given** el globo recibe knockback cerca de un borde
   - **When** el impulso lo empuja hacia el borde
   - **Then** el globo no puede salir de pantalla; los límites siguen activos

---

### Edge Cases

- ¿Qué pasa si el globo recibe dos golpes seguidos durante el freeze? → El segundo golpe
  resetea el timer del freeze e inicia un nuevo flash de color desde rojo.
- ¿Qué pasa si el jugador pausa durante el freeze? → El juego se pausa normalmente;
  al reanudar el freeze continúa si no expiró.
- ¿El freeze afecta las fuerzas del director (lluvia, aspiradora)? → No. Solo bloquea
  el input directo del jugador; las fuerzas externas siguen aplicándose.

---

## Requirements

### Functional Requirements

- **FR-HURT-001**: Al recibir un golpe, el globo (incluye calavera) DEBE cambiar inmediatamente
  a un tinte rojo fuerte (modulate).
- **FR-HURT-002**: El tinte rojo DEBE desvanecerse gradualmente volviendo al color normal
  en ~0.4 segundos.
- **FR-HURT-003**: El input del jugador (mechero y movimiento lateral) DEBE desactivarse
  durante ~0.3 segundos tras el golpe.
- **FR-HURT-004**: La física (gravedad, fuerzas externas, inercia) DEBE seguir activa
  durante el freeze de input.
- **FR-HURT-005**: El globo DEBE recibir un impulso de velocidad en la dirección del
  knockback con magnitud moderada (~150–200 px de desplazamiento desde el punto de impacto).
- **FR-HURT-006**: El visual_root.scale NO DEBE cambiar durante ni después del knockback;
  la animación de squish/stretch queda eliminada.
- **FR-HURT-007**: Los límites de pantalla DEBEN seguir activos durante el knockback.
- **FR-HURT-008**: Si ocurre un segundo golpe durante el freeze, el efecto DEBE resetearse:
  nuevo flash de rojo y nuevo timer de freeze.

### Key Entities

- **Estado de golpe (HitState)**: Estado temporal del globo tras un golpe. Dura ~0.3–0.4s.
  Durante este estado el input está bloqueado y el visual tiene tinte rojo.

---

## Success Criteria

### Measurable Outcomes

- **SC-HURT-001**: El flash de color rojo es claramente perceptible (tinte fuerte, no sutil).
- **SC-HURT-002**: El freeze de input dura entre 0.2 y 0.4 segundos.
- **SC-HURT-003**: El globo NO cambia de escala en ningún momento durante el knockback.
- **SC-HURT-004**: El jugador recupera el control completo pasado el freeze sin estado residual.
- **SC-HURT-005**: El impulso desplaza al globo ~150–200 px sin que llegue al borde en
  condiciones normales (globo en posición central o de juego habitual).
