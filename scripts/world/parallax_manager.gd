class_name ParallaxManager
extends Node2D
## Gestiona el scroll automático del fondo parallax y el cambio de fondos (F1).
## Soporta N capas dinámicas configurables via LAYER_CONFIGS.
## Los ParallaxLayer se crean en _ready(); parallax_world.tscn solo necesita el nodo
## ParallaxBackground vacío — no hay hijos hardcodeados en la escena.

@export var scroll_speed: float  = 80.0   ## Velocidad de scroll horizontal (px/s)
@export var fade_duration: float = 1.5    ## Duración del cross-fade al cambiar fondo (s)

# ── Configuración de capas ────────────────────────────────────────────────────
## Definición global de slots: cada entrada genera un ParallaxLayer en _ready().
## El índice del array es el slot que usan los BACKGROUND_SETS para asignar texturas.
## Slots con z_index > 0 se renderizan delante del player (z_index = 0 por defecto).
const LAYER_CONFIGS: Array = [
	{"scroll_x": 0.2, "z_index": -2},  # slot 0: fondo lejano
	{"scroll_x": 0.5, "z_index": -1},  # slot 1: fondo medio
	{"scroll_x": 1.0, "z_index": 0},   # slot 2: fondo cercano (al nivel del player)
	{"scroll_x": 1.5, "z_index": 2},   # slot 3: frontal (delante del player)
]

# ── Sets de fondo ─────────────────────────────────────────────────────────────
## Cada entrada tiene "textures": Array donde índice i corresponde al slot i de LAYER_CONFIGS.
## Slots sin textura: "" o ausentes → sprite invisible.
## Agregar más entradas para tener más fondos ciclables con F1.
const BACKGROUND_SETS: Array = [
	# sky_clouds/set_01: 4 capas — incluye frontal (slot 3, delante del globo)
	{"textures": [
		"res://assets/backgrounds/sky_clouds/set_01/layer_01.png",
		"res://assets/backgrounds/sky_clouds/set_01/layer_02.png",
		"res://assets/backgrounds/sky_clouds/set_01/layer_03.png",
		"res://assets/backgrounds/sky_clouds/set_01/layer_04.png",
	]},
	# sky_clouds/set_03: 4 capas — incluye frontal
	{"textures": [
		"res://assets/backgrounds/sky_clouds/set_03/layer_01.png",
		"res://assets/backgrounds/sky_clouds/set_03/layer_02.png",
		"res://assets/backgrounds/sky_clouds/set_03/layer_03.png",
		"res://assets/backgrounds/sky_clouds/set_03/layer_04.png",
	]},
	# post_apocalypse/set_01: 3 capas — sin capa frontal
	{"textures": [
		"res://assets/backgrounds/post_apocalypse/set_01/layer_01.png",
		"res://assets/backgrounds/post_apocalypse/set_01/layer_02.png",
		"res://assets/backgrounds/post_apocalypse/set_01/layer_03.png",
		"",  # slot 3: sin capa frontal
	]},
]

# ── Nodos ─────────────────────────────────────────────────────────────────────
@onready var parallax_bg: ParallaxBackground = $ParallaxBackground

# ── Estado ────────────────────────────────────────────────────────────────────
var _current_index: int = 0
var _fading: bool = false
var _layers: Array[ParallaxLayer] = []
# Dos sprites por capa para cross-fade verdadero: A=visible, B=siguiente
var _sprites_a: Array[Sprite2D] = []
var _sprites_b: Array[Sprite2D] = []

var _bird_layer: ParallaxLayer = null  ## Capa de pájaros activable por F4

func _ready() -> void:
	_create_layers()
	_create_layer_sprites()
	_load_background(_current_index, _sprites_a)
	GameManager.background_change.connect(_on_background_change)
	GameManager.birds_toggled.connect(toggle_birds)

func _process(delta: float) -> void:
	parallax_bg.scroll_base_offset.x -= scroll_speed * delta

# ── Creación de capas ─────────────────────────────────────────────────────────
func _create_layers() -> void:
	for i in LAYER_CONFIGS.size():
		var cfg: Dictionary = LAYER_CONFIGS[i]
		var layer := ParallaxLayer.new()
		layer.name = "Layer_%d" % i
		layer.motion_scale = Vector2(cfg["scroll_x"], 0.0)
		layer.z_index = cfg["z_index"]
		parallax_bg.add_child(layer)
		_layers.append(layer)

# ── Creación de sprites ───────────────────────────────────────────────────────
func _create_layer_sprites() -> void:
	for layer in _layers:
		var sprite_a := _make_sprite()
		var sprite_b := _make_sprite()
		sprite_b.modulate.a = 0.0
		layer.add_child(sprite_a)
		layer.add_child(sprite_b)
		_sprites_a.append(sprite_a)
		_sprites_b.append(sprite_b)

func _make_sprite() -> Sprite2D:
	var s := Sprite2D.new()
	s.centered = false
	s.position = Vector2.ZERO
	return s

# ── Carga de texturas ─────────────────────────────────────────────────────────
func _load_background(index: int, sprites: Array[Sprite2D]) -> void:
	if BACKGROUND_SETS.is_empty():
		return
	var set_data: Dictionary = BACKGROUND_SETS[index % BACKGROUND_SETS.size()]
	var textures: Array = set_data.get("textures", [])
	var vp_size: Vector2 = get_viewport_rect().size
	for i in LAYER_CONFIGS.size():
		var path: String = textures[i] if i < textures.size() else ""
		if path == "":
			sprites[i].texture = null
			continue
		if not ResourceLoader.exists(path):
			push_warning("ParallaxManager: textura no encontrada — " + path)
			sprites[i].texture = null
			continue
		sprites[i].texture = load(path)
		var tex_size: Vector2 = sprites[i].texture.get_size()
		# Escalar el sprite para cubrir el viewport completo (texturas 576x324 → 1280x720)
		var scale_factor := vp_size.y / tex_size.y
		sprites[i].scale = Vector2(scale_factor, scale_factor)
		# motion_mirroring usa el ancho escalado para que el tiling sea sin costura
		_layers[i].motion_mirroring = Vector2(tex_size.x * scale_factor, 0.0)

# ── Cambio de fondo con cross-fade ────────────────────────────────────────────
func next_background() -> void:
	if _fading:
		return
	_fading = true
	_current_index = (_current_index + 1) % BACKGROUND_SETS.size()
	_load_background(_current_index, _sprites_b)

	var tween := create_tween().set_parallel(true)
	for i in _sprites_a.size():
		tween.tween_property(_sprites_a[i], "modulate:a", 0.0, fade_duration)
		tween.tween_property(_sprites_b[i], "modulate:a", 1.0, fade_duration)
	tween.finished.connect(_on_fade_complete, CONNECT_ONE_SHOT)

func _on_fade_complete() -> void:
	# Intercambiar referencias: A pasa a ser el visible, B queda lista para el próximo cambio
	var tmp: Array[Sprite2D] = _sprites_a
	_sprites_a = _sprites_b
	_sprites_b = tmp
	for s in _sprites_b:
		s.modulate.a = 0.0
	_fading = false

func _on_background_change() -> void:
	next_background()

# ── Capa de pájaros (F4) ──────────────────────────────────────────────────────
## Patrón Phase 5b: capa creada por código, no en tscn. Placeholder con Polygon2D.
## Reemplazar _make_bird_shape() con AnimatedSprite2D cuando haya assets reales.
func toggle_birds(active: bool) -> void:
	if active and _bird_layer == null:
		_create_bird_layer()
	elif not active and _bird_layer != null:
		_bird_layer.queue_free()
		_bird_layer = null

func _create_bird_layer() -> void:
	_bird_layer = ParallaxLayer.new()
	_bird_layer.name = "BirdLayer"
	_bird_layer.motion_scale = Vector2(2.5, 0.0)
	_bird_layer.z_index = 1   # delante del player (z=0), detrás del frontal (z=2)
	_bird_layer.motion_mirroring = Vector2(1280.0, 0.0)
	parallax_bg.add_child(_bird_layer)

	# 8 pájaros distribuidos dentro del ancho de mirroring, en la franja superior
	var xs: Array = [0, 160, 300, 480, 580, 750, 900, 1080]
	var ys: Array = [80, 50, 120, 70, 100, 60, 90, 140]
	for i in xs.size():
		var bird := _make_bird_shape()
		bird.position = Vector2(xs[i], ys[i])
		_bird_layer.add_child(bird)

func _make_bird_shape() -> Polygon2D:
	var p := Polygon2D.new()
	# Silueta de pájaro en vuelo: chevron/V abierta
	p.polygon = PackedVector2Array([
		Vector2(-14, 5), Vector2(-7, 0), Vector2(0, -4),
		Vector2(7, 0), Vector2(14, 5),
		Vector2(9, 7), Vector2(0, 3), Vector2(-9, 7)
	])
	p.color = Color(0.08, 0.08, 0.10, 0.85)
	return p
