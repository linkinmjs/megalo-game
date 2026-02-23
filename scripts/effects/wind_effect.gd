class_name WindEffect
extends Node2D
## Efecto de viento: partículas horizontales y fuerza lateral sobre el globo.
## Toggle ON/OFF via GameManager.wind_toggled (F3).

signal wind_force_changed(force: float)  ## Emitido al activar/desactivar. 0 = sin fuerza.

@export var lateral_force: float = 100.0  ## Fuerza lateral aplicada al globo (px/s)

@onready var _particles: CPUParticles2D = $WindParticles

func _ready() -> void:
	_particles.emitting = false
	GameManager.wind_toggled.connect(_on_wind_toggled)

func _on_wind_toggled(active: bool) -> void:
	_particles.emitting = active
	wind_force_changed.emit(lateral_force if active else 0.0)
