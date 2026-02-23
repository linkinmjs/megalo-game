class_name RainCloud
extends Node2D
## Nube de lluvia que sigue al globo torpemente y aplica fuerza hacia abajo cuando está activa.
## Toggle ON/OFF via GameManager.rain_toggled (F2).
## La referencia al target (globo) se asigna desde main_scene.gd en _ready.

signal rain_force_changed(force: float)  ## Emitido al entrar/salir del área. 0 = sin fuerza.

@export var follow_speed: float    = 1.2    ## Factor lerp para seguir al target (torpe/con retraso)
@export var rain_down_force: float = 120.0  ## Fuerza downward (px/s²) cuando el globo está bajo la nube

var target: Node2D = null  ## Referencia al globo, asignada externamente por main_scene.gd

@onready var _particles: CPUParticles2D = $RainParticles
@onready var _effect_area: Area2D       = $EffectArea

var _active: bool       = false
var _body_in_area: bool = false

func _ready() -> void:
	modulate.a = 0.0
	_particles.emitting = false
	_effect_area.body_entered.connect(_on_body_entered)
	_effect_area.body_exited.connect(_on_body_exited)
	GameManager.rain_toggled.connect(_on_rain_toggled)

func _process(delta: float) -> void:
	if target == null or not _active:
		return
	# Seguir al player torpemente: solo en X, 200px arriba en Y
	var target_pos := Vector2(target.global_position.x, target.global_position.y - 200.0)
	position = position.lerp(target_pos, follow_speed * delta)

func _on_rain_toggled(active: bool) -> void:
	_active = active
	_particles.emitting = active
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0 if active else 0.0, 0.5)
	if not active:
		_body_in_area = false
		rain_force_changed.emit(0.0)

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("receive_rain_force") and _active:
		_body_in_area = true
		rain_force_changed.emit(rain_down_force)

func _on_body_exited(body: Node2D) -> void:
	if body.has_method("receive_rain_force"):
		_body_in_area = false
		rain_force_changed.emit(0.0)
