extends Node

var current_scene: PackedScene = null
var current_scene_instance: Node = null

var config = ConfigFile.new()

@onready var camera_2d = $Camera2D

var bumpscosity: int = 0

func _process(_delta):
	camera_2d.position.y = 324 + sin(Time.get_ticks_msec() / 1000.0 * (bumpscosity / 10.0)) * bumpscosity
	
	if Input.is_action_just_pressed("fullscreen"):
		_toggle_fullscreen()

## INSTRUCTIONS AS TO HOW TO USE SCENE TRANSITIONS

## This script contains 2 functions for loading scenes: _change_scene, and _fade_transition.
## They both do the exact same thing, but fade transition spices it up with a hip and snazzy powerpoint transition. 
## Simply call either of them from another script ('reference_variable'._change_scene('scene_name') ) and it might work.
## Make sure the scene is inside the 'scenes' folder, and add any sub-folders to the function paramaters.

## Eg. res://scenes/menu/different_buttons/stupid_button.tscn would be _change_scene("menu/different_buttons/stupid_button")
# Also I haven't tested this so if it breaks then it is broken


func _restart_music():
	print("music restart")
	if song_loop:
		active_player.play(0)

var song_loop: bool = true


func _stop_music():
	if active_player != null:
		active_player.stop()

func _ready():
	
	# Make sure that no config things have null value
	_config_load_stuff()
	
	_change_scene("menu/main_menu")
	#_change_scene("platformer/mafia_bossfight")
	
	_fix_music_volume()
	
	music.finished.connect(_restart_music)
	music_2.finished.connect(_restart_music)

var save_file = "user://save_DATA.spinglespongle"

func _toggle_fullscreen():
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _save_DATA(save_game: bool):
	var DATA_file = FileAccess.open(save_file, FileAccess.WRITE)
	
	var output: String = ""
	
	if DATA_file:
		if save_game:
			output += "1\n"
		else:
			output += "0\n"
		
		print("DATA saved! It's this thing vvvvvvvvv\n" + output)
		DATA_file.store_string(output)
	else:
		printerr("CAN'T FIND THE DATA FILE AAAAAHAHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH (this is where it should be: " + str(save_file) + ")")


func _change_scene(scene_name: String):
	# Murder the living scene if it exists
	if current_scene_instance != null:
		remove_child(current_scene_instance)
		current_scene_instance.queue_free()
	
	# Give birth to the new scene
	current_scene = load("res://scenes/" + scene_name + ".tscn")
	if current_scene != null:
		current_scene_instance = current_scene.instantiate()
		
		add_child(current_scene_instance)
	else:
		current_scene = load("res://scenes/misc/error_screen.tscn")
		current_scene_instance = current_scene.instantiate()
		add_child(current_scene_instance)
		
		printerr("Error: Miscarriage while birthing ", scene_name)

var path = "user://config.cfg"

func _config_load_stuff():
	
	if config.load(path) != OK:
		_reset_config()
		return
	
	var audio_exists = config.has_section("audio")
	var master_exists = config.get_value("audio", "master_volume", null)
	var sound_exists = config.get_value("audio", "sound_volume", null)
	var music_exists = config.get_value("audio", "music_volume", null)
	
	if audio_exists && master_exists != null && sound_exists != null && music_exists != null:
		DATA.master_volume = config.get_value("audio", "master_volume")
		DATA.sound_volume = config.get_value("audio", "sound_volume")
		DATA.music_volume = config.get_value("audio", "music_volume")
	else:
		_reset_config()

func _config_save_stuff():
	config.set_value("audio", "master_volume", DATA.master_volume)
	config.set_value("audio", "sound_volume", DATA.sound_volume)
	config.set_value("audio", "music_volume", DATA.music_volume)
	
	print_rich("[color=green]Audio settings saved:\n[color=yellow]MASTER: " + str(DATA.master_volume) + "\nSOUND: " + str(DATA.sound_volume) + "\nMUSIC " + str(DATA.music_volume))
	
	config.save(path)

func _reset_config():
	print("Resetting config settings")
	
	config.set_value("audio", "master_volume", 0.5)
	config.set_value("audio", "sound_volume", 1.0)
	config.set_value("audio", "music_volume", 1.0)
	
	DATA.master_volume = 0.5
	DATA.sound_volume = 1.0
	DATA.music_volume = 1.0
	
	config.save(path)

func _fade_transition(scene_name: String, transin_time: float = 0.5, hold_black: float = 0.0, transout_time: float = 0.5, camera_node: Camera2D = $Camera2D):
	
	var black_screen_pointer = preload("res://scenes/misc/black_screen.tscn")
	
	var black_screen = black_screen_pointer.instantiate()
	black_screen.modulate.a = 0
	
	add_child(black_screen)
	
	var time_passed_transition: float = 0
	
	while black_screen.modulate.a < 1:
		black_screen.modulate.a = lerpf(0, 1, time_passed_transition / transin_time)
		black_screen.global_position = camera_node.global_position
		
		time_passed_transition += get_process_delta_time()
		
		await get_tree().process_frame
	
	await get_tree().create_timer(hold_black).timeout
	
	await _change_scene(scene_name)
	
	var time_passed: float = 0
	
	while black_screen.modulate.a > 0:
		black_screen.modulate.a = lerpf(1, 0, (time_passed - transin_time) / transout_time)
		
		time_passed += get_process_delta_time()
		
		await get_tree().process_frame

var music_low: float = 0.0
var music_high: float = 1.0

@onready var music: AudioStreamPlayer = $music
@onready var music_2: AudioStreamPlayer = $music2

var music_1_selected: bool = true

var active_player: AudioStreamPlayer

var music_fade_length: float = 2

var music_tween: Tween

func _play_music(song: String):
	
	if music_tween:
		music_tween.kill()
	
	music_tween = create_tween()
	
	active_player = music if music.playing else music_2
	var next_player = music_2 if music.playing else music
	
	var m_path: String = ""
	var loop: bool = true
	
	music_tween.tween_property(active_player, "volume_linear", 0, music_fade_length).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	match song:
		"menu":
			m_path = "res://audio/Life on the Edge.ogg"
			music_high = 1.0
			loop = true
		"grandma_house":
			m_path = "res://audio/What's Up Grandma.ogg"
			music_high = 1.0
			loop = true
		"tutorial":
			m_path = "res://audio/Touch of Grass.ogg"
			music_high = 1.0
			loop = true
		"bee_fight":
			m_path = "res://audio/Flight of the Killer B.ogg"
			music_high = 1.1
			loop = true
		"death":
			m_path = "res://audio/Edge of Life.ogg"
			music_high = 1.0
			loop = true
		"mafia fight":
			m_path = "res://audio/Flight of the Killer B.ogg"
			music_high = 1.0
			loop = true
	
	next_player.stream = load(m_path)
	next_player.volume_linear = 0 # Start silent
	next_player.play()
	
	# Fade out active, Fade in next
	
	music_tween.parallel().tween_property(next_player, "volume_linear", DATA.master_volume * DATA.music_volume * music_high, music_fade_length).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	await music_tween.finished
	
	active_player.stop()
	
	song_loop = loop
	
	active_player = next_player

func _fix_music_volume():
	music.volume_linear = DATA.master_volume * music_high * DATA.music_volume
