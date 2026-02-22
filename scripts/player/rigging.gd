extends Node2D
## Actualiza dinámicamente los 4 Line2D que representan las cuerdas del rigging.
## Cada cuerda tiene un punto de anclaje fijo en el BalloonSprite y otro en el SkullSprite.
## Se añade un punto medio con caída catenaria para dar apariencia de cuerda real.

@onready var balloon_sprite: Sprite2D  = $"../BalloonSprite"
@onready var skull_sprite:   Sprite2D  = $"../SkullPivot/SkullSprite"

## Anclajes en espacio local de BalloonSprite (escala 1.0, 320×320 px)
const BALLOON_ANCHORS: Array[Vector2] = [
	Vector2(-50, 120),
	Vector2(-33, 126),
	Vector2( 14, 125),
	Vector2( 47, 120),
]

## Anclajes en espacio local de SkullSprite (escala 0.45, 320×320 px)
const SKULL_ANCHORS: Array[Vector2] = [
	Vector2(-73, -104),
	Vector2(-36,  -98),
	Vector2( 18,  -98),
	Vector2( 58, -104),
]

## Caída catenaria: fracción de la distancia entre puntas que cae el punto medio
const SAG_FRACTION: float = 0.08

func _process(_delta: float) -> void:
	var lines := get_children()
	for i in mini(lines.size(), BALLOON_ANCHORS.size()):
		var line := lines[i] as Line2D
		if not line:
			continue

		# Convertir anclajes a espacio global y luego a espacio local de Rigging
		var p_top  : Vector2 = to_local(balloon_sprite.to_global(BALLOON_ANCHORS[i]))
		var p_bot  : Vector2 = to_local(skull_sprite.to_global(SKULL_ANCHORS[i]))

		# Punto medio con caída catenaria (sag hacia abajo)
		var mid    : Vector2 = (p_top + p_bot) * 0.5
		var dist   : float   = p_top.distance_to(p_bot)
		mid.y += dist * SAG_FRACTION

		line.points = PackedVector2Array([p_top, mid, p_bot])
