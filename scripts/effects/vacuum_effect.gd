class_name VacuumEffect
extends Node2D
## Aspiradora gigante que asoma desde el borde izquierdo y succiona al globo.
## Reemplaza WindEffect. Toggle via GameManager.wind_toggled (F3).

signal suction_force_changed(force: float)

@export var suction_force:  float = 120.0  ## Fuerza de atracción hacia la izquierda (px/s)
@export var anim_duration:  float = 0.40   ## Duración del slide de entrada/salida (s)

@onready var _particles_container: Node2D = $SuctionParticles
@onready var _lines_container:     Node2D = $SuctionLines

var _active: bool = false
var _tween:  Tween = null
var _suction_lines:  Array[Line2D]       = []
var _line_base_points: Array             = []  ## puntos base (sin onda)
var _particles_list: Array[CPUParticles2D] = []

func _ready() -> void:
	var vp_half_w := get_viewport_rect().size.x * 0.5
	position = Vector2(-(vp_half_w + 270.0), 0.0)
	# Recolectar emisores de partículas
	for child in _particles_container.get_children():
		if child is CPUParticles2D:
			child.emitting = false
			_particles_list.append(child as CPUParticles2D)
	# Recolectar líneas y guardar sus puntos base para la animación de onda
	for child in _lines_container.get_children():
		if child is Line2D:
			_suction_lines.append(child as Line2D)
			var pts := []
			for j in (child as Line2D).get_point_count():
				pts.append((child as Line2D).get_point_position(j))
			_line_base_points.append(pts)
			child.visible = false
	GameManager.wind_toggled.connect(_on_wind_toggled)

func _process(_delta: float) -> void:
	if not _active:
		return
	# Onda que viaja de derecha a izquierda — simula corriente de succión
	var t := Time.get_ticks_msec() / 1000.0
	for i in _suction_lines.size():
		var line: Line2D  = _suction_lines[i]
		var base: Array   = _line_base_points[i]
		for j in line.get_point_count():
			var progress := float(j) / float(line.get_point_count() - 1)
			var wave := sin(t * 4.5 - progress * TAU * 1.5 + float(i) * 1.1) * 13.0
			line.set_point_position(j, Vector2(base[j].x, base[j].y + wave))

func _on_wind_toggled(active: bool) -> void:
	_active = active
	if _tween:
		_tween.kill()
	var vp_half_w := get_viewport_rect().size.x * 0.5
	# Activo: la boca queda ~60px dentro del borde izquierdo
	var target_x := -(vp_half_w - 60.0) if active else -(vp_half_w + 270.0)
	_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	_tween.tween_property(self, "position:x", target_x, anim_duration)
	for p in _particles_list:
		p.emitting = active
	for line in _suction_lines:
		line.visible = active
	suction_force_changed.emit(-suction_force if active else 0.0)
