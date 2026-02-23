class_name BirdsController
extends Node2D
## Pájaros marioneta que descienden desde arriba al activar F4.
## Cada pájaro lleva un hilo visible (Line2D) que simula animación de marioneta.
## Lógica independiente del parallax — se conecta directamente a GameManager.birds_toggled.

@export var bird_count:    int   = 8
@export var rest_y:        float = -150.0  ## Posición Y estable (relativa al centro de pantalla)
@export var scroll_speed:  float = 120.0   ## Velocidad de desplazamiento horizontal (px/s)
@export var anim_duration: float = 1.0     ## Duración de la animación de descenso/ascenso (s)

var _active:    bool    = false
var _container: Node2D  = null  ## Contiene todos los pájaros; se anima en Y
var _tween:     Tween   = null

func _ready() -> void:
	GameManager.birds_toggled.connect(_on_birds_toggled)

func _process(delta: float) -> void:
	if _container == null:
		return
	# Desplazamiento horizontal en loop suave
	_container.position.x -= scroll_speed * delta
	var mirror_width := 1280.0
	if _container.position.x < -mirror_width:
		_container.position.x += mirror_width

func _on_birds_toggled(active: bool) -> void:
	_active = active
	if _tween:
		_tween.kill()
	if active:
		_create_birds()
		var vp_hh := get_viewport_rect().size.y * 0.5
		_container.position.y = -(vp_hh + 100.0)  # fuera de pantalla, arriba
		_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		_tween.tween_property(_container, "position:y", rest_y, anim_duration)
	else:
		if _container == null:
			return
		var vp_hh := get_viewport_rect().size.y * 0.5
		_tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		_tween.tween_property(_container, "position:y", -(vp_hh + 100.0), anim_duration)
		_tween.tween_callback(func(): _destroy_birds())

func _create_birds() -> void:
	_container = Node2D.new()
	_container.z_index = 1
	add_child(_container)
	var xs := _spread_xs(bird_count, 1280.0)
	for x in xs:
		var bird := _make_bird_marionette()
		bird.position = Vector2(x - 640.0, 0.0)
		_container.add_child(bird)

func _destroy_birds() -> void:
	if _container:
		_container.queue_free()
	_container = null

func _spread_xs(n: int, total_width: float) -> Array:
	var xs := []
	for i in n:
		xs.append(total_width * i / n + randf() * 60.0)
	return xs

func _make_bird_marionette() -> Node2D:
	var root := Node2D.new()
	# Silueta del pájaro en vuelo (chevron/V abierta)
	var bird := Polygon2D.new()
	bird.polygon = PackedVector2Array([
		Vector2(-14, 5), Vector2(-7, 0), Vector2(0, -4),
		Vector2(7, 0),   Vector2(14, 5),
		Vector2(9, 7),   Vector2(0, 3),  Vector2(-9, 7)
	])
	bird.color = Color(0.08, 0.08, 0.10, 0.90)
	root.add_child(bird)
	# Hilo de marioneta: desde el pájaro hacia arriba, 700px
	var thread := Line2D.new()
	thread.add_point(Vector2(0, 0))
	thread.add_point(Vector2(0, -700))
	thread.width = 1.0
	thread.default_color = Color(0.15, 0.15, 0.18, 0.65)
	root.add_child(thread)
	return root
