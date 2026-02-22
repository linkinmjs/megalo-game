extends Control
## Pantalla de Settings accesible desde el menú principal.
## Los cambios de volumen se aplican en tiempo real y se persisten en user://settings.cfg

const SETTINGS_PATH := "user://settings.cfg"

@onready var slider_music: HSlider = $VBoxContainer/MusicRow/SliderMusic
@onready var slider_sfx: HSlider = $VBoxContainer/SFXRow/SliderSFX
@onready var btn_back: Button = $VBoxContainer/BtnBack

var _bus_music: int = -1
var _bus_sfx: int = -1

func _ready() -> void:
	_bus_music = AudioServer.get_bus_index("Music")
	_bus_sfx   = AudioServer.get_bus_index("SFX")

	_load_settings()

	slider_music.value_changed.connect(_on_music_changed)
	slider_sfx.value_changed.connect(_on_sfx_changed)
	btn_back.pressed.connect(_on_back_pressed)

func _on_music_changed(value: float) -> void:
	if _bus_music >= 0:
		AudioServer.set_bus_volume_db(_bus_music, linear_to_db(value))
	_save_settings()

func _on_sfx_changed(value: float) -> void:
	if _bus_sfx >= 0:
		AudioServer.set_bus_volume_db(_bus_sfx, linear_to_db(value))
	_save_settings()

func _on_back_pressed() -> void:
	GameManager.change_scene(GameManager.settings_return_scene)

func _save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "music", slider_music.value)
	cfg.set_value("audio", "sfx",   slider_sfx.value)
	cfg.save(SETTINGS_PATH)

func _load_settings() -> void:
	var cfg := ConfigFile.new()
	var music_val := 1.0
	var sfx_val   := 1.0

	if cfg.load(SETTINGS_PATH) == OK:
		music_val = cfg.get_value("audio", "music", 1.0)
		sfx_val   = cfg.get_value("audio", "sfx",   1.0)

	# Asignar sin disparar value_changed todavía
	slider_music.set_value_no_signal(music_val)
	slider_sfx.set_value_no_signal(sfx_val)

	# Aplicar a los buses
	if _bus_music >= 0:
		AudioServer.set_bus_volume_db(_bus_music, linear_to_db(music_val))
	if _bus_sfx >= 0:
		AudioServer.set_bus_volume_db(_bus_sfx, linear_to_db(sfx_val))
