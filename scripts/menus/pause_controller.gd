extends CanvasLayer
## Menú de pausa. Se activa con Escape durante el gameplay.
## process_mode = ALWAYS para recibir input y ejecutar Tweens mientras el árbol está pausado.

const FADE_OUT_DURATION := 1.0
const FADE_IN_DURATION  := 0.5

# Paneles
@onready var backdrop:       ColorRect = $Backdrop
@onready var pause_panel:    Control   = $PausePanel
@onready var settings_panel: Control   = $SettingsPanel

# Botones — panel de pausa
@onready var btn_resume:   Button = $PausePanel/VBox/BtnResume
@onready var btn_settings: Button = $PausePanel/VBox/BtnSettings
@onready var btn_quit:     Button = $PausePanel/VBox/BtnQuit

# Sliders — panel de settings embebido
@onready var slider_music: HSlider = $SettingsPanel/VBox/MusicRow/SliderMusic
@onready var slider_sfx:   HSlider = $SettingsPanel/VBox/SFXRow/SliderSFX
@onready var btn_back:     Button  = $SettingsPanel/VBox/BtnBack

var _is_paused: bool = false
var _fade_tween: Tween = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	backdrop.visible       = false
	pause_panel.visible    = false
	settings_panel.visible = false

	btn_resume.pressed.connect(_on_resume)
	btn_settings.pressed.connect(_show_settings_panel)
	btn_quit.pressed.connect(_on_quit)
	btn_back.pressed.connect(_show_pause_panel)

	slider_music.value_changed.connect(_on_music_changed)
	slider_sfx.value_changed.connect(_on_sfx_changed)

	_load_slider_values()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if settings_panel.visible:
			_show_pause_panel()
		elif _is_paused:
			_on_resume()
		else:
			_do_pause()

# ── Pausa / Reanuda ────────────────────────────────────────────────────────────
func _do_pause() -> void:
	_is_paused = true
	get_tree().paused = true
	backdrop.visible    = true
	pause_panel.visible = true
	_fade_music_out()

func _on_resume() -> void:
	_is_paused = false
	backdrop.visible       = false
	pause_panel.visible    = false
	settings_panel.visible = false
	_fade_music_in()
	get_tree().paused = false

# ── Fade de música ─────────────────────────────────────────────────────────────
func _fade_music_out() -> void:
	var mp := GameManager.music_player
	if mp == null:
		return
	if _fade_tween:
		_fade_tween.kill()
	_fade_tween = create_tween()
	_fade_tween.tween_property(mp, "volume_db", -80.0, FADE_OUT_DURATION)
	_fade_tween.tween_callback(func() -> void: mp.stream_paused = true)

func _fade_music_in() -> void:
	var mp := GameManager.music_player
	if mp == null:
		return
	if _fade_tween:
		_fade_tween.kill()
	mp.stream_paused = false
	_fade_tween = create_tween()
	_fade_tween.tween_property(mp, "volume_db", 0.0, FADE_IN_DURATION)

# ── Navegación entre paneles ───────────────────────────────────────────────────
func _show_settings_panel() -> void:
	pause_panel.visible    = false
	settings_panel.visible = true

func _show_pause_panel() -> void:
	settings_panel.visible = false
	pause_panel.visible    = true

func _on_quit() -> void:
	_is_paused = false
	backdrop.visible = false
	get_tree().paused = false
	GameManager.change_scene("main_menu")

# ── Settings embebido ──────────────────────────────────────────────────────────
func _on_music_changed(value: float) -> void:
	var bus := AudioServer.get_bus_index("Music")
	if bus >= 0:
		AudioServer.set_bus_volume_db(bus, linear_to_db(value))
	_save_settings()

func _on_sfx_changed(value: float) -> void:
	var bus := AudioServer.get_bus_index("SFX")
	if bus >= 0:
		AudioServer.set_bus_volume_db(bus, linear_to_db(value))
	_save_settings()

func _save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "music", slider_music.value)
	cfg.set_value("audio", "sfx",   slider_sfx.value)
	cfg.save("user://settings.cfg")

func _load_slider_values() -> void:
	var cfg := ConfigFile.new()
	var music_val := 1.0
	var sfx_val   := 1.0
	if cfg.load("user://settings.cfg") == OK:
		music_val = cfg.get_value("audio", "music", 1.0)
		sfx_val   = cfg.get_value("audio", "sfx",   1.0)
	slider_music.set_value_no_signal(music_val)
	slider_sfx.set_value_no_signal(sfx_val)
