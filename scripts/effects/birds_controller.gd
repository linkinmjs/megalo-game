class_name BirdsController
extends Node2D
## Pájaros marioneta que descienden desde arriba y scrollean hacia la izquierda.
## Al activar F4: oleada inicial + spawn continuo. Al desactivar: todos ascienden y se destruyen.
## Cada pájaro lleva un hilo visible (Line2D) de 700px hacia arriba.

@export var bird_count:     int   = 8    ## Pájaros en la oleada inicial
@export var rest_y:         float = -150.0  ## Posición Y estable (relativa al centro)
@export var scroll_speed:   float = 120.0   ## Velocidad de scroll horizontal (px/s)
@export var anim_duration:  float = 1.0     ## Duración de descenso/ascenso (s)
@export var spawn_interval: float = 1.2     ## Segundos entre spawns individuales

var _active:      bool              = false
var _spawn_timer: float             = 0.0
var _birds:       Array[Node2D]     = []  ## Pájaros activos en escena

func _ready() -> void:
	GameManager.birds_toggled.connect(_on_birds_toggled)

func _process(delta: float) -> void:
	if not _active:
		return

	# Scroll izquierda + destruir los que salen de pantalla
	var left_limit := -(get_viewport_rect().size.x * 0.5 + 100.0)
	var to_remove: Array[Node2D] = []
	for bird in _birds:
		bird.position.x -= scroll_speed * delta
		if bird.position.x < left_limit:
			to_remove.append(bird)
	for bird in to_remove:
		_birds.erase(bird)
		bird.queue_free()

	# Spawn continuo
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_timer = spawn_interval
		_spawn_one()

func _on_birds_toggled(active: bool) -> void:
	_active = active
	if active:
		_spawn_initial_wave()
		_spawn_timer = spawn_interval
	else:
		_ascend_all()

# ── Spawn ──────────────────────────────────────────────────────────────────────

func _spawn_initial_wave() -> void:
	var vp := get_viewport_rect().size
	var xs := _spread_xs(bird_count, vp.x)
	for x in xs:
		var bird := _make_bird_marionette()
		bird.position = Vector2(x - vp.x * 0.5, -(vp.y * 0.5 + 100.0))
		add_child(bird)
		_birds.append(bird)
		_tween_down(bird)

func _spawn_one() -> void:
	var vp := get_viewport_rect().size
	# Aparece desde el borde derecho con jitter
	var x := vp.x * 0.5 + randf_range(30.0, 180.0)
	var bird := _make_bird_marionette()
	bird.position = Vector2(x, -(vp.y * 0.5 + 100.0))
	add_child(bird)
	_birds.append(bird)
	_tween_down(bird)

func _tween_down(bird: Node2D) -> void:
	var tw := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(bird, "position:y", rest_y, anim_duration)

func _ascend_all() -> void:
	var vp_hh := get_viewport_rect().size.y * 0.5
	var target_y := -(vp_hh + 100.0)
	for bird in _birds:
		var tw := create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		tw.tween_property(bird, "position:y", target_y, anim_duration)
		tw.tween_callback(_free_bird.bind(bird))
	_birds.clear()

func _free_bird(bird: Node2D) -> void:
	if is_instance_valid(bird):
		bird.queue_free()

# ── Helpers ────────────────────────────────────────────────────────────────────

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
