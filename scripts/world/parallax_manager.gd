extends Node2D
## Gestiona el scroll automático del fondo parallax y el cambio de fondos (F1).

@export var scroll_speed: float = 80.0

@onready var parallax_bg: ParallaxBackground = $ParallaxBackground

func _ready() -> void:
	GameManager.background_change.connect(_on_background_change)

func _process(delta: float) -> void:
	parallax_bg.scroll_base_offset.x -= scroll_speed * delta

func _on_background_change() -> void:
	# TODO Phase 5: cargar siguiente fondo con cross-fade
	pass
