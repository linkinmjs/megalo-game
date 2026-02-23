class_name ObstacleBase
extends Area2D
## Obstáculo base: atraviesa la pantalla horizontalmente y aplica knockback al globo.
## Dirección +1 = izquierda→derecha; -1 = derecha→izquierda.
## Se auto-destruye al salir de pantalla.

signal hit_balloon

@export var speed: float          = 150.0   ## Velocidad de desplazamiento (px/s)
@export var direction: float      = 1.0     ## +1 = izq→der, -1 = der→izq
@export var knockback_force: float = 350.0  ## Fuerza del impulso aplicado al globo

const _DESTROY_X: float = 750.0  ## Se destruye cuando |position.x| supera este valor

var _hit: bool = false  ## Evita aplicar knockback más de una vez por obstáculo

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	position.x += direction * speed * delta
	if absf(position.x) > _DESTROY_X:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if _hit:
		return
	if body.has_method("apply_knockback"):
		_hit = true
		# Knockback en la dirección del obstáculo + leve componente hacia arriba
		var knockback_dir := Vector2(direction, -0.25).normalized()
		body.apply_knockback(knockback_dir, knockback_force)
		hit_balloon.emit()
