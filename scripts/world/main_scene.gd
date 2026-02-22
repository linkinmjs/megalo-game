extends Node2D
## Script raíz de la escena de juego.
## Registra el MusicPlayer en el GameManager para que pause_controller pueda encontrarlo.

@onready var music_player: AudioStreamPlayer = $MusicPlayer

func _ready() -> void:
	GameManager.music_player = music_player

	# Si hay un archivo de audio cargado, reproducir automáticamente
	if music_player.stream != null:
		music_player.play()
