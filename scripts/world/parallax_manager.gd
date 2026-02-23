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
## Slots 0-3 iguales a antes; slots 4-6 nuevos para sets con 5-7 capas.
## Slots con z_index > 0 se renderizan delante del player (z_index = 0 por defecto).
const LAYER_CONFIGS: Array = [
	{"scroll_x": 0.2,  "z_index": -2},  # slot 0: fondo lejano
	{"scroll_x": 0.5,  "z_index": -1},  # slot 1: fondo medio
	{"scroll_x": 1.0,  "z_index":  0},  # slot 2: fondo cercano (al nivel del player)
	{"scroll_x": 1.5,  "z_index":  2},  # slot 3: frontal (delante del player)
	{"scroll_x": 2.0,  "z_index":  3},  # slot 4: muy frontal
	{"scroll_x": 2.6,  "z_index":  4},  # slot 5: primer plano
	{"scroll_x": 3.2,  "z_index":  5},  # slot 6: primer plano cercano
]

# ── Sets de fondo ─────────────────────────────────────────────────────────────
## Cada entrada tiene "textures": Array donde índice i corresponde al slot i de LAYER_CONFIGS.
## Slots sin textura: "" o ausentes → sprite invisible (el código maneja arrays más cortos).
## 20 sets en total: sky_clouds ×8, nature ×4, post_apocalypse ×4, city_ruins ×4.
const BACKGROUND_SETS: Array = [
	# ── sky_clouds ──────────────────────────────────────────────────────────────
	{"textures": [  # sky_clouds/set_01 — 4 capas
		"res://assets/backgrounds/sky_clouds/set_01/layer_01.png",
		"res://assets/backgrounds/sky_clouds/set_01/layer_02.png",
		"res://assets/backgrounds/sky_clouds/set_01/layer_03.png",
		"res://assets/backgrounds/sky_clouds/set_01/layer_04.png",
	]},
	{"textures": [  # sky_clouds/set_02 — 4 capas
		"res://assets/backgrounds/sky_clouds/set_02/layer_01.png",
		"res://assets/backgrounds/sky_clouds/set_02/layer_02.png",
		"res://assets/backgrounds/sky_clouds/set_02/layer_03.png",
		"res://assets/backgrounds/sky_clouds/set_02/layer_04.png",
	]},
	{"textures": [  # sky_clouds/set_03 — 4 capas
		"res://assets/backgrounds/sky_clouds/set_03/layer_01.png",
		"res://assets/backgrounds/sky_clouds/set_03/layer_02.png",
		"res://assets/backgrounds/sky_clouds/set_03/layer_03.png",
		"res://assets/backgrounds/sky_clouds/set_03/layer_04.png",
	]},
	{"textures": [  # sky_clouds/set_04 — 4 capas
		"res://assets/backgrounds/sky_clouds/set_04/layer_01.png",
		"res://assets/backgrounds/sky_clouds/set_04/layer_02.png",
		"res://assets/backgrounds/sky_clouds/set_04/layer_03.png",
		"res://assets/backgrounds/sky_clouds/set_04/layer_04.png",
	]},
	{"textures": [  # sky_clouds/set_05 — 5 capas
		"res://assets/backgrounds/sky_clouds/set_05/layer_01.png",
		"res://assets/backgrounds/sky_clouds/set_05/layer_02.png",
		"res://assets/backgrounds/sky_clouds/set_05/layer_03.png",
		"res://assets/backgrounds/sky_clouds/set_05/layer_04.png",
		"res://assets/backgrounds/sky_clouds/set_05/layer_05.png",
	]},
	{"textures": [  # sky_clouds/set_06 — 6 capas
		"res://assets/backgrounds/sky_clouds/set_06/layer_01.png",
		"res://assets/backgrounds/sky_clouds/set_06/layer_02.png",
		"res://assets/backgrounds/sky_clouds/set_06/layer_03.png",
		"res://assets/backgrounds/sky_clouds/set_06/layer_04.png",
		"res://assets/backgrounds/sky_clouds/set_06/layer_05.png",
		"res://assets/backgrounds/sky_clouds/set_06/layer_06.png",
	]},
	{"textures": [  # sky_clouds/set_07 — 4 capas
		"res://assets/backgrounds/sky_clouds/set_07/layer_01.png",
		"res://assets/backgrounds/sky_clouds/set_07/layer_02.png",
		"res://assets/backgrounds/sky_clouds/set_07/layer_03.png",
		"res://assets/backgrounds/sky_clouds/set_07/layer_04.png",
	]},
	{"textures": [  # sky_clouds/set_08 — 6 capas
		"res://assets/backgrounds/sky_clouds/set_08/layer_01.png",
		"res://assets/backgrounds/sky_clouds/set_08/layer_02.png",
		"res://assets/backgrounds/sky_clouds/set_08/layer_03.png",
		"res://assets/backgrounds/sky_clouds/set_08/layer_04.png",
		"res://assets/backgrounds/sky_clouds/set_08/layer_05.png",
		"res://assets/backgrounds/sky_clouds/set_08/layer_06.png",
	]},
	# ── nature ──────────────────────────────────────────────────────────────────
	{"textures": [  # nature/set_01 — 3 capas
		"res://assets/backgrounds/nature/set_01/layer_01.png",
		"res://assets/backgrounds/nature/set_01/layer_02.png",
		"res://assets/backgrounds/nature/set_01/layer_03.png",
	]},
	{"textures": [  # nature/set_02 — 4 capas
		"res://assets/backgrounds/nature/set_02/layer_01.png",
		"res://assets/backgrounds/nature/set_02/layer_02.png",
		"res://assets/backgrounds/nature/set_02/layer_03.png",
		"res://assets/backgrounds/nature/set_02/layer_04.png",
	]},
	{"textures": [  # nature/set_03 — 5 capas
		"res://assets/backgrounds/nature/set_03/layer_01.png",
		"res://assets/backgrounds/nature/set_03/layer_02.png",
		"res://assets/backgrounds/nature/set_03/layer_03.png",
		"res://assets/backgrounds/nature/set_03/layer_04.png",
		"res://assets/backgrounds/nature/set_03/layer_05.png",
	]},
	{"textures": [  # nature/set_04 — 7 capas
		"res://assets/backgrounds/nature/set_04/layer_01.png",
		"res://assets/backgrounds/nature/set_04/layer_02.png",
		"res://assets/backgrounds/nature/set_04/layer_03.png",
		"res://assets/backgrounds/nature/set_04/layer_04.png",
		"res://assets/backgrounds/nature/set_04/layer_05.png",
		"res://assets/backgrounds/nature/set_04/layer_06.png",
		"res://assets/backgrounds/nature/set_04/layer_07.png",
	]},
	# ── post_apocalypse ─────────────────────────────────────────────────────────
	{"textures": [  # post_apocalypse/set_01 — 3 capas
		"res://assets/backgrounds/post_apocalypse/set_01/layer_01.png",
		"res://assets/backgrounds/post_apocalypse/set_01/layer_02.png",
		"res://assets/backgrounds/post_apocalypse/set_01/layer_03.png",
	]},
	{"textures": [  # post_apocalypse/set_02 — 4 capas
		"res://assets/backgrounds/post_apocalypse/set_02/layer_01.png",
		"res://assets/backgrounds/post_apocalypse/set_02/layer_02.png",
		"res://assets/backgrounds/post_apocalypse/set_02/layer_03.png",
		"res://assets/backgrounds/post_apocalypse/set_02/layer_04.png",
	]},
	{"textures": [  # post_apocalypse/set_03 — 4 capas
		"res://assets/backgrounds/post_apocalypse/set_03/layer_01.png",
		"res://assets/backgrounds/post_apocalypse/set_03/layer_02.png",
		"res://assets/backgrounds/post_apocalypse/set_03/layer_03.png",
		"res://assets/backgrounds/post_apocalypse/set_03/layer_04.png",
	]},
	{"textures": [  # post_apocalypse/set_04 — 4 capas
		"res://assets/backgrounds/post_apocalypse/set_04/layer_01.png",
		"res://assets/backgrounds/post_apocalypse/set_04/layer_02.png",
		"res://assets/backgrounds/post_apocalypse/set_04/layer_03.png",
		"res://assets/backgrounds/post_apocalypse/set_04/layer_04.png",
	]},
	# ── city_ruins ──────────────────────────────────────────────────────────────
	{"textures": [  # city_ruins/set_01 — 5 capas
		"res://assets/backgrounds/city_ruins/set_01/layer_01.png",
		"res://assets/backgrounds/city_ruins/set_01/layer_02.png",
		"res://assets/backgrounds/city_ruins/set_01/layer_03.png",
		"res://assets/backgrounds/city_ruins/set_01/layer_04.png",
		"res://assets/backgrounds/city_ruins/set_01/layer_05.png",
	]},
	{"textures": [  # city_ruins/set_02 — 6 capas
		"res://assets/backgrounds/city_ruins/set_02/layer_01.png",
		"res://assets/backgrounds/city_ruins/set_02/layer_02.png",
		"res://assets/backgrounds/city_ruins/set_02/layer_03.png",
		"res://assets/backgrounds/city_ruins/set_02/layer_04.png",
		"res://assets/backgrounds/city_ruins/set_02/layer_05.png",
		"res://assets/backgrounds/city_ruins/set_02/layer_06.png",
	]},
	{"textures": [  # city_ruins/set_03 — 7 capas
		"res://assets/backgrounds/city_ruins/set_03/layer_01.png",
		"res://assets/backgrounds/city_ruins/set_03/layer_02.png",
		"res://assets/backgrounds/city_ruins/set_03/layer_03.png",
		"res://assets/backgrounds/city_ruins/set_03/layer_04.png",
		"res://assets/backgrounds/city_ruins/set_03/layer_05.png",
		"res://assets/backgrounds/city_ruins/set_03/layer_06.png",
		"res://assets/backgrounds/city_ruins/set_03/layer_07.png",
	]},
	{"textures": [  # city_ruins/set_04 — 7 capas
		"res://assets/backgrounds/city_ruins/set_04/layer_01.png",
		"res://assets/backgrounds/city_ruins/set_04/layer_02.png",
		"res://assets/backgrounds/city_ruins/set_04/layer_03.png",
		"res://assets/backgrounds/city_ruins/set_04/layer_04.png",
		"res://assets/backgrounds/city_ruins/set_04/layer_05.png",
		"res://assets/backgrounds/city_ruins/set_04/layer_06.png",
		"res://assets/backgrounds/city_ruins/set_04/layer_07.png",
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

func _ready() -> void:
	_create_layers()
	_create_layer_sprites()
	_load_background(_current_index, _sprites_a)
	GameManager.background_change.connect(_on_background_change)

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
	# Identificar el set por la primera textura (para debug)
	var set_name: String = textures[0].get_base_dir().trim_prefix("res://assets/backgrounds/") if textures.size() > 0 else "vacío"
	print("ParallaxManager [set %d/%d]: %s (%d capas)" % [index + 1, BACKGROUND_SETS.size(), set_name, textures.size()])
	var vp_size: Vector2 = get_viewport_rect().size
	# Restaurar scroll de todas las capas (por si el set anterior tenía última capa estática)
	for i in _layers.size():
		_layers[i].motion_scale.x = LAYER_CONFIGS[i]["scroll_x"]
	var last_loaded_slot := -1
	for i in LAYER_CONFIGS.size():
		var path: String = textures[i] if i < textures.size() else ""
		if path == "":
			sprites[i].texture = null
			sprites[i].position = Vector2.ZERO
			continue
		if not ResourceLoader.exists(path):
			print("  ✗ slot %d — NO ENCONTRADA: %s" % [i, path])
			sprites[i].texture = null
			sprites[i].position = Vector2.ZERO
			continue
		sprites[i].texture = load(path)
		sprites[i].position = Vector2.ZERO
		var tex_size: Vector2 = sprites[i].texture.get_size()
		# Escalar el sprite para cubrir el viewport completo
		var scale_factor := vp_size.y / tex_size.y
		sprites[i].scale = Vector2(scale_factor, scale_factor)
		# motion_mirroring usa el ancho escalado para tiling sin costura
		_layers[i].motion_mirroring = Vector2(tex_size.x * scale_factor, 0.0)
		print("  ✓ slot %d — %s (%.0fx%.0f → escala %.2f)" % [i, path.get_file(), tex_size.x, tex_size.y, scale_factor])
		last_loaded_slot = i
	# La última capa cargada es estática: sin scroll, sin tiling, centrada en viewport
	if last_loaded_slot >= 0:
		_layers[last_loaded_slot].motion_scale = Vector2.ZERO
		_layers[last_loaded_slot].motion_mirroring = Vector2.ZERO
		sprites[last_loaded_slot].position = -vp_size * 0.5
		print("  → slot %d marcado como estático (sin parallax)" % last_loaded_slot)

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
