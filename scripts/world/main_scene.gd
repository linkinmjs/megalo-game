extends Node2D
## Script raíz de la escena de juego.
## Registra el MusicPlayer en el GameManager y cablea señales de efectos → globo.

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var balloon:      Node2D            = $GameWorld/Balloon
@onready var rain_cloud:   RainCloud         = $GameWorld/RainCloud
@onready var vacuum_effect: VacuumEffect     = $GameWorld/VacuumEffect

func _ready() -> void:
	GameManager.music_player = music_player
	_load_music()

	# Asignar target de la nube (la sigue torpemente)
	rain_cloud.target = balloon

	# Cablear fuerzas de efectos → globo via señales
	rain_cloud.rain_force_changed.connect(balloon.receive_rain_force)
	vacuum_effect.suction_force_changed.connect(balloon.receive_wind_force)

func _load_music() -> void:
	var dir := DirAccess.open("res://assets/audio/")
	if dir == null:
		push_warning("MainScene: carpeta assets/audio/ no encontrada")
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".mp3") or file_name.ends_with(".ogg"):
			var stream = load("res://assets/audio/" + file_name)
			if stream:
				stream.loop = true
				music_player.stream = stream
				music_player.play()
				return
		file_name = dir.get_next()

	push_warning("MainScene: no se encontró audio en assets/audio/")
