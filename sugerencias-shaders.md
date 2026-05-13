# Sugerencias de Shaders para el Director

**Contexto**: Los shaders existentes son VHS (F6), aberración cromática (F7) y pixelado (F8).
Todos siguen el mismo contrato: `boost = 0.0` → invisible/sin efecto, `boost = 1.0` → máximo exagerado.
Las sugerencias respetan ese mismo contrato.

---

## 1. Scanlines CRT

**Qué hace**: Superpone líneas horizontales oscuras finas sobre toda la pantalla, como si fuera un
monitor de tubo catódico. A boost bajo, apenas visibles. A boost máximo, franjas gruesas y muy marcadas.

**Por qué es buena**: Complementa naturalmente el VHS — juntos construyen una estética de grabación
analógica de los 80s/90s completa. Es el par obvio del VHS y el más reconocible de todos los efectos
retro. Muy poco costoso de renderizar.

---

## 2. Vignette + Desaturación

**Qué hace**: Oscurece progresivamente los bordes de la pantalla (vignette) al tiempo que desatura
los colores hacia escala de grises. A boost bajo, un borde oscuro sutil. A boost máximo, los bordes
son negros y el centro casi sin color.

**Por qué es buena**: Es el efecto cinematográfico por excelencia para crear tensión y foco central.
Útil para momentos dramáticos de la canción: la imagen se "cierra" visualmente sobre el globo,
reforzando que algo importante está pasando. También funciona bien para presentar el glitch previo
al fake crash si se lo combina con los otros shaders.

---

## 3. Bloom / Glow

**Qué hace**: Las zonas brillantes de la imagen "sangran" luz hacia los píxeles vecinos. Las áreas
claras se expanden con un halo suave. A boost bajo, solo los blancos tienen un glow tenue. A boost
máximo, toda la pantalla sobreexpuesta, luz desbordándose por todos lados.

**Por qué es buena**: El look steampunk del juego tiene muchos elementos metálicos y brillantes.
El bloom los hace resaltar de forma dramática. También crea un look "onírico" o de memoria idealizada
que contrasta bien con la estética oxidada del VHS. El contraste boost bajo / boost alto es muy
telegénico — la cámara de video lo capta bien.

---

## 4. Duotone / Bicolor

**Qué hace**: Reemplaza el rango de colores completo con solo dos tonos configurables (uno para las
sombras, otro para las luces). A boost bajo, los colores originales se ven con un tinte sutil. A boost
máximo, la imagen es completamente bicolor — como un cartel de Shepard Fairey.

**Por qué es buena**: Permite cambiar el *mood* de la escena de forma radical con un solo parámetro.
Duotone azul/naranja para ciencia ficción, rojo/amarillo para peligro, sepia/crema para nostalgia.
Como los colores son `@export`, el director puede elegir la paleta antes de la grabación para que
encaje con la sección de la canción. Es el efecto más "artístico" de la lista.

---

## 5. Ojo de Pez (Barrel Distortion)

**Qué hace**: Curva la imagen hacia afuera como una lente de ojo de pez (barril) o hacia adentro
(cojín). A boost bajo, una distorsión imperceptible. A boost máximo, la imagen se curva de forma
extrema — los bordes se doblan hacia adelante como una pantalla convexa.

**Por qué es buena**: Rompe la "ventana perfecta" del juego. Hace que la cámara parezca un lente
especial, una cámara de seguridad o una cámara de acción. Combinado con el VHS, refuerza la ilusión
de que estamos viendo footage grabado con equipamiento cuestionable. El contraste con el resto de
la estética es lo que lo hace poderoso.

---

## 6. Glitch de Bloques

**Qué hace**: Divide la pantalla en bloques rectangulares aleatorios que se desplazan
horizontalmente con offsets caóticos. Diferente del VHS (que desplaza líneas individuales): esto
desplaza *segmentos grandes*, como una corrupción de datos más severa. A boost bajo, un bloque
ocasional se mueve levemente. A boost máximo, la imagen se fragmenta en piezas que se solapan.

**Por qué es buena**: Es el efecto más "digital" de todos — vs el VHS que es analógico. Juntos
cubren dos tipos de corrupción visual completamente distintos. Este shader es particularmente
efectivo para el glitch previo al fake crash: si el VHS hace la corrupción analógica inicial,
el glitch de bloques puede hacer la corrupción digital final antes del BSOD.

---

## 7. Zoom Blur Radial

**Qué hace**: Aplica un blur radial desde el centro de la pantalla — como si la cámara estuviera
haciendo un zoom muy rápido. A boost bajo, apenas un halo de movimiento en los bordes. A boost
máximo, el efecto es de velocidad extrema: el centro está nítido y los bordes "fluyen" hacia él.

**Por qué es buena**: Es la forma más rápida y barata de comunicar *velocidad* o *impacto* sin
mover nada en la escena. En un videoclip, los drops de batería o los momentos de clímax musical
quedan muy bien con este efecto boosteado brevemente y luego removido. También funciona como
efecto de "mareo" o desorientación si el globo choca con algo.

---

## 8. Rotación de Matiz (Hue Rotate)

**Qué hace**: Rota el matiz (hue) de todos los colores de la imagen progresivamente. A boost bajo,
un tinte apenas perceptible. A boost máximo, los colores han rotado tanto que el cielo es rojo,
el globo es verde — todo psicotrópico.

**Por qué es buena**: Es el efecto más *psicodélico* de la lista y el que más personalidad tiene
en movimiento. Como el matiz puede rotar continuamente (con `TIME`), puede configurarse para que a
boost máximo los colores giren en tiempo real — la imagen literalmente "arde" con colores cambiantes.
Ideal para secciones experimentales de la canción donde se busca desorientar al espectador.

---

## 9. Ondas / Heat Haze

**Qué hace**: Distorsiona la imagen con ondas sinusoidales horizontales y verticales, como si la
escena estuviera vista a través de aire caliente o agua. A boost bajo, una oscilación casi
imperceptible. A boost máximo, la imagen ondula agresivamente — como estar bajo el agua o en un
sueño.

**Por qué es buena**: Crea una sensación de *delirio* o alucinación sin corrupción — diferente del
glitch que implica falla técnica, esto implica estado alterado. En el contexto del videoclip, funciona
bien para secciones introspectivas o lisérgicas de la canción. Combinado con el bloom (efecto 3),
produce una estética de calor sofocante muy específica.

---

## 10. Estático de TV (Snow)

**Qué hace**: Agrega ruido blanco y negro de alta frecuencia (como la "nieve" de un canal sin señal
de TV analógica). A boost bajo, un leve granulado encima de la imagen. A boost máximo, toda la
pantalla se convierte en estático puro — la imagen del juego desaparece bajo el ruido.

**Por qué es buena**: Es el único efecto que puede *ocultar* completamente la imagen sin hacer un
fundido a negro. Funciona como transición: boost de 0 a 1 = la imagen se "pierde" en estático,
boost de 1 a 0 = el juego "emerge" del ruido. En el contexto del fake crash, es una alternativa
dramática al glitch de bloques para el momento inmediatamente previo al BSOD — la señal se pierde.

---

## Resumen comparativo

| # | Shader | Estética base | Mejor momento en el videoclip |
|---|--------|---------------|-------------------------------|
| 1 | Scanlines CRT | Retro analógico | Todo el tiempo, base de TV |
| 2 | Vignette + Desaturación | Cinematográfico | Momentos dramáticos / tensos |
| 3 | Bloom / Glow | Onírico / overexposed | Drops, clímax, momentos épicos |
| 4 | Duotone | Artístico / cartelismo | Secciones temáticas de la canción |
| 5 | Ojo de Pez | Cámara de seguridad | Caos, loops, momentos de locura |
| 6 | Glitch de Bloques | Corrupción digital | Pre-crash, glitches de sistema |
| 7 | Zoom Blur Radial | Velocidad / impacto | Drops, golpes, cambios de tempo |
| 8 | Hue Rotate | Psicodélico | Secciones experimentales |
| 9 | Ondas / Heat Haze | Delirio / sueño | Secciones introspectivas |
| 10 | Estático de TV | Señal perdida | Transiciones, pre-crash |

---

*Próximo paso recomendado: corré `/sdd-spec` para el conjunto de shaders que quieras implementar,*
*luego `/sdd-plan` para agregar las tareas al plan.*
