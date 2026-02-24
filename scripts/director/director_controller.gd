extends Node
## Controlador del Director — teclas F1–F8 para eventos en tiempo real.
## No tiene UI visible. Solo emite señales hacia GameManager.

## Intervalos de spawn por nivel de intensidad (nivel 1–4)
const INTENSITY_INTERVALS: Array[float] = [6.0, 3.0, 1.5, 0.75]

@export var double_tap_window: float = 0.5   ## Ventana para detectar double-tap en F5 (s)
@export var boost_rise_speed: float  = 0.7   ## Velocidad de subida del boost de shader (u/s)
@export var boost_fall_speed: float  = 2.0   ## Velocidad de bajada al soltar F7 (u/s)

var _rain_active: bool = false
var _wind_active: bool = false
var _birds_active: bool = false

var _intensity_level: int = 0       ## Nivel actual de spawn (0 = off, 1–4 = activo)
var _last_f5_press: float = -1.0    ## Timestamp del último press de F5 (-1 = ninguno)

var _shader_index: int = 0          ## Mirror local del shader activo
var _boost_level: float = 0.0       ## Nivel de potenciado del shader (0.0–1.0)

func _process(delta: float) -> void:
	var held := Input.is_key_pressed(KEY_7)
	if held:
		_boost_level = min(_boost_level + boost_rise_speed * delta, 1.0)
	else:
		_boost_level = max(_boost_level - boost_fall_speed * delta, 0.0)
	GameManager.apply_shader_boost(_boost_level)

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return

	match event.keycode:
		KEY_1:
			GameManager.background_change.emit()
		KEY_2:
			_rain_active = not _rain_active
			GameManager.rain_toggled.emit(_rain_active)
		KEY_3:
			_wind_active = not _wind_active
			GameManager.wind_toggled.emit(_wind_active)
		KEY_4:
			_birds_active = not _birds_active
			GameManager.birds_toggled.emit(_birds_active)
		KEY_5:
			_handle_f5()
		KEY_6:
			_shader_index = max(_shader_index - 1, 0)
			_boost_level = 0.0
			GameManager.set_active_shader(_shader_index)
		KEY_8:
			_shader_index = min(_shader_index + 1, 2)
			_boost_level = 0.0
			GameManager.set_active_shader(_shader_index)
		KEY_9:
			_boost_level = 0.0
			GameManager.toggle_shader()


func _handle_f5() -> void:
	var now := Time.get_ticks_msec() / 1000.0
	if _last_f5_press >= 0.0 and now - _last_f5_press < double_tap_window:
		# double-tap → reset a nivel 0
		_intensity_level = 0
		_last_f5_press = -1.0
		GameManager.obstacle_intensity_changed.emit(0)
	else:
		# press normal: subir nivel si no está al máximo
		_last_f5_press = now
		if _intensity_level < 4:
			_intensity_level += 1
			GameManager.obstacle_intensity_changed.emit(_intensity_level)
		# en nivel 4: _last_f5_press se actualiza igual → permite double-tap reset
