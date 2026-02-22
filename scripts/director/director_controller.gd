extends Node
## Controlador del Director — teclas F1–F5 para eventos en tiempo real.
## No tiene UI visible. Solo emite señales hacia GameManager.

var _rain_active: bool = false
var _wind_active: bool = false
var _birds_active: bool = false

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
			GameManager.event_director.emit("spawn_obstacle")
