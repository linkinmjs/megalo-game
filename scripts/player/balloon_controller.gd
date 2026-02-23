extends CharacterBody2D
## Controlador del globo aerostático (player).
## Física de mechero/gravedad, límites de pantalla, inflado del sprite del globo,
## sway amortiguado de la calavera y knockback con squish/stretch.

# ── Señales ────────────────────────────────────────────────────────────────────
signal burner_activated()
signal burner_deactivated()

# ── Física ─────────────────────────────────────────────────────────────────────
@export_group("Physics")
@export var gravity: float            = 400.0
@export var burner_force: float       = 600.0
@export var max_vertical_speed: float = 420.0
@export var lateral_speed: float      = 200.0
@export var screen_margin: float      = 60.0   ## Margen en px desde el borde de pantalla
@export var top_overflow: float       = 80.0   ## Cuántos px puede sobresalir por arriba

# ── Inflado del globo ──────────────────────────────────────────────────────────
@export_group("Balloon Inflate")
@export var balloon_inflate_scale: float = 1.06  ## Escala máxima al inflar (1.0 = normal)
@export var balloon_inflate_speed: float = 3.0   ## Velocidad de lerp del inflado

# ── Sway de la calavera ────────────────────────────────────────────────────────
@export_group("Skull Sway")
@export var skull_sway_factor: float      = 0.08   ## Respuesta lateral (bajo = poco sway)
@export var skull_sway_damping: float     = 8.0    ## Velocidad de retorno al centro (alto = más rígido)
@export var skull_vertical_response: float = 0.04  ## Respuesta vertical
@export var skull_tilt_factor: float      = 0.001  ## Inclinación por vel. lateral (rad por unidad/s); ~10° a vel. máxima

# ── Nodos ──────────────────────────────────────────────────────────────────────
@onready var visual_root:    Node2D        = $VisualRoot
@onready var balloon_sprite: Sprite2D      = $VisualRoot/BalloonSprite
@onready var skull_pivot:    Node2D        = $VisualRoot/SkullPivot
@onready var burner_flame:   CPUParticles2D = $VisualRoot/BurnerFlame

# ── Estado interno ─────────────────────────────────────────────────────────────
var _burner_active: bool = false
var _skull_rest_pos: Vector2
var _squish_tween: Tween = null
# Fuerzas externas acumuladas (efectos del Director)
var _wind_force: float = 0.0   ## Fuerza lateral sostenida (px/s) — set por WindEffect
var _rain_force: float = 0.0   ## Fuerza hacia abajo (px/s²) — set por RainCloud

func _ready() -> void:
	_skull_rest_pos = skull_pivot.position

func _physics_process(delta: float) -> void:
	_handle_input(delta)
	_apply_screen_limits()
	move_and_slide()
	_update_balloon_inflate(delta)
	_update_skull_sway(delta)

# ── Input ──────────────────────────────────────────────────────────────────────
func _handle_input(delta: float) -> void:
	var burner_on := (Input.is_key_pressed(KEY_SPACE)
		or Input.is_key_pressed(KEY_W)
		or Input.is_key_pressed(KEY_UP))

	if burner_on:
		velocity.y -= burner_force * delta
		if not _burner_active:
			_burner_active = true
			burner_flame.emitting = true
			burner_activated.emit()
	else:
		velocity.y += gravity * delta
		if _burner_active:
			_burner_active = false
			burner_flame.emitting = false
			burner_deactivated.emit()

	# Fuerza adicional de lluvia (downward)
	velocity.y += _rain_force * delta
	velocity.y = clamp(velocity.y, -max_vertical_speed, max_vertical_speed)

	# Movimiento lateral: velocidad directa (no acumulada) → frena al soltar
	var lateral := 0.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		lateral = -1.0
	elif Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		lateral = 1.0
	# _wind_force se suma al movimiento lateral del jugador
	velocity.x = lateral * lateral_speed + _wind_force

# ── Límites de pantalla ────────────────────────────────────────────────────────
## Coordenadas con cámara DRAG_CENTER: (0,0) = centro del viewport.
func _apply_screen_limits() -> void:
	var vp := get_viewport_rect()
	var hw := vp.size.x * 0.5
	var hh := vp.size.y * 0.5

	# Laterales — hard clamp
	if position.x < -hw + screen_margin:
		position.x = -hw + screen_margin
		velocity.x = maxf(velocity.x, 0.0)
	elif position.x > hw - screen_margin:
		position.x = hw - screen_margin
		velocity.x = minf(velocity.x, 0.0)

	# Inferior — hard clamp
	if position.y > hh - screen_margin:
		position.y = hh - screen_margin
		velocity.y = minf(velocity.y, 0.0)

	# Superior — soft limit: puede salir top_overflow px, luego frena
	if position.y < -hh - top_overflow:
		position.y = -hh - top_overflow
		velocity.y = maxf(velocity.y, 0.0)

# ── Inflado del globo (solo balloon_sprite) ────────────────────────────────────
func _update_balloon_inflate(delta: float) -> void:
	var target := balloon_inflate_scale if _burner_active else 1.0
	var new_s := lerpf(balloon_sprite.scale.x, target, balloon_inflate_speed * delta)
	balloon_sprite.scale = Vector2(new_s, new_s)

# ── Sway de la calavera (lerp puro, sin spring) ────────────────────────────────
func _update_skull_sway(delta: float) -> void:
	var target_x := _skull_rest_pos.x - velocity.x * skull_sway_factor
	var target_y := _skull_rest_pos.y - velocity.y * skull_vertical_response
	skull_pivot.position.x = lerpf(skull_pivot.position.x, target_x, skull_sway_damping * delta)
	skull_pivot.position.y = lerpf(skull_pivot.position.y, target_y, skull_sway_damping * delta)
	# Inclinación: adelante (vel.x > 0) → rota en sentido horario (mira levemente abajo)
	#              atrás  (vel.x < 0) → rota en sentido antihorario (mira levemente arriba)
	var target_rot := velocity.x * skull_tilt_factor
	skull_pivot.rotation = lerpf(skull_pivot.rotation, target_rot, skull_sway_damping * delta)

# ── Fuerzas externas del Director (lluvia / viento) ───────────────────────────
func receive_wind_force(force: float) -> void:
	_wind_force = force

func receive_rain_force(force: float) -> void:
	_rain_force = force

# ── Knockback (llamado por obstáculos) ─────────────────────────────────────────
func apply_knockback(direction: Vector2, force: float) -> void:
	velocity += direction.normalized() * force
	_play_squish()

func _play_squish() -> void:
	if _squish_tween:
		_squish_tween.kill()
	# Squish en visual_root para afectar ambos sprites sin tocar CollisionShape2D
	visual_root.scale = Vector2.ONE
	_squish_tween = create_tween()
	_squish_tween.set_ease(Tween.EASE_OUT)
	_squish_tween.set_trans(Tween.TRANS_BACK)
	_squish_tween.tween_property(visual_root, "scale", Vector2(1.3, 0.7), 0.10)
	_squish_tween.tween_property(visual_root, "scale", Vector2(0.88, 1.12), 0.10)
	_squish_tween.tween_property(visual_root, "scale", Vector2(1.0, 1.0), 0.18)
