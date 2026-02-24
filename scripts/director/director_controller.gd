extends Node
## Controlador del Director — teclas F1–F8 para eventos en tiempo real.
## No tiene UI visible. Solo emite señales hacia GameManager.

## Intervalos de spawn por nivel de intensidad (nivel 1–4)
const INTENSITY_INTERVALS: Array[float] = [6.0, 3.0, 1.5, 0.75]

@export var double_tap_window: float = 0.5  ## Ventana para detectar double-tap en F5 (s)

var _rain_active: bool = false
var _wind_active: bool = false
var _birds_active: bool = false

var _intensity_level: int = 0       ## Nivel actual de spawn (0 = off, 1–4 = activo)
var _last_f5_press: float = -1.0    ## Timestamp del último press de F5 (-1 = ninguno)

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return

	match event.keycode:
		KEY_F1:
			GameManager.background_change.emit()
		KEY_F2:
			_rain_active = not _rain_active
			GameManager.rain_toggled.emit(_rain_active)
		KEY_F3:
			_wind_active = not _wind_active
			GameManager.wind_toggled.emit(_wind_active)
		KEY_F4:
			_birds_active = not _birds_active
			GameManager.birds_toggled.emit(_birds_active)
		KEY_F5:
			_handle_f5()


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
