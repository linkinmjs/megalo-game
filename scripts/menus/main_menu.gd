extends Control

@onready var btn_play: Button = $VBoxContainer/BtnPlay
@onready var btn_settings: Button = $VBoxContainer/BtnSettings
@onready var ambient_player: AudioStreamPlayer = $AmbientPlayer

func _ready() -> void:
	btn_play.pressed.connect(_on_play_pressed)
	btn_settings.pressed.connect(_on_settings_pressed)

	if ambient_player.stream != null:
		ambient_player.play()

func _on_play_pressed() -> void:
	GameManager.change_scene("game")

func _on_settings_pressed() -> void:
	GameManager.change_scene("settings", "main_menu")
