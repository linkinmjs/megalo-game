class_name ObstacleSpawner
extends Node2D
## Genera obstáculos en intervalos controlados por el Director (F5).
## El timer empieza parado; se activa y configura vía obstacle_intensity_changed.
## Posiciona cada obstáculo en el borde de pantalla opuesto a su dirección de movimiento.

## Intervalos de spawn por nivel de intensidad (índice = nivel-1)
const INTENSITY_INTERVALS: Array[float] = [6.0, 3.0, 1.5, 0.75]

@export var y_range: float = 240.0  ## Mitad del rango vertical de aparición (px)
@export var ashtray_scene: PackedScene  ## Escena del cenicero (izq→der)
@export var bottle_scene: PackedScene   ## Escena del frasco (der→izq)

const _SPAWN_X: float = 700.0  ## Posición X de spawn (fuera de pantalla)

@onready var _timer: Timer = $Timer

func _ready() -> void:
	_timer.timeout.connect(_on_timer_timeout)
	# El timer empieza parado — solo arranca cuando el director activa el spawn
	GameManager.obstacle_intensity_changed.connect(_on_intensity_changed)

func _on_timer_timeout() -> void:
	_spawn_random()

func _on_intensity_changed(level: int) -> void:
	if level == 0:
		_timer.stop()
	else:
		_timer.wait_time = INTENSITY_INTERVALS[level - 1]
		_timer.start()
		_spawn_random()  # spawn inmediato como confirmación visual

func _spawn_random() -> void:
	var scenes: Array = [ashtray_scene, bottle_scene]
	var scene: PackedScene = scenes[randi() % scenes.size()]
	if scene == null:
		push_warning("ObstacleSpawner: escena no asignada — verificar exports en el inspector")
		return

	var obstacle: ObstacleBase = scene.instantiate() as ObstacleBase
	if obstacle == null:
		return

	# Agregar al padre del spawner (GameWorld) para que los obstáculos
	# compartan el mismo espacio de coordenadas que el globo
	get_parent().add_child(obstacle)

	# Posición X según dirección: direction>0 viene de la izquierda, <0 de la derecha
	var spawn_x := -_SPAWN_X if obstacle.direction > 0.0 else _SPAWN_X
	var random_y := randf_range(-y_range, y_range)
	obstacle.global_position = Vector2(spawn_x, random_y)
