extends Node2D
## Script raíz de la escena de juego.
## Registra el MusicPlayer en el GameManager y cablea señales de efectos → globo.

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var balloon:      Node2D            = $GameWorld/Balloon
@onready var rain_cloud:   RainCloud         = $GameWorld/RainCloud
@onready var wind_effect:  WindEffect        = $GameWorld/WindEffect

func _ready() -> void:
	GameManager.music_player = music_player
	if music_player.stream != null:
		music_player.play()

	# Asignar target de la nube (la sigue torpemente)
	rain_cloud.target = balloon

	# Cablear fuerzas de efectos → globo via señales
	rain_cloud.rain_force_changed.connect(balloon.receive_rain_force)
	wind_effect.wind_force_changed.connect(balloon.receive_wind_force)
