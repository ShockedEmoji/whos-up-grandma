extends Node2D

@onready var master_slider = $parent/master_slider
@onready var music_slider = $parent/music_slider
@onready var sound_slider = $parent/sound_slider

@onready var fullscreen: Button = $parent/fullscreen

@onready var leave = $parent/leave
@onready var animation_player = $parent/AnimationPlayer

func _ready():
	
	master_slider.value = DATA.master_volume * 100
	music_slider.value = DATA.music_volume * 100
	sound_slider.value = DATA.sound_volume * 100
	
	master_slider.value_changed.connect(_edit_volume)
	master_slider.drag_ended.connect(_save_config)
	
	music_slider.value_changed.connect(_edit_volume)
	music_slider.drag_ended.connect(_save_config)
	
	sound_slider.value_changed.connect(_edit_volume)
	sound_slider.drag_ended.connect(_save_config)
	
	leave.pressed.connect(_close)
	
	fullscreen.pressed.connect(_toggle_fullscreen)

func _toggle_fullscreen():
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	$"../.."._play_sound("click")

func _edit_volume(_ignore):
	DATA.master_volume = master_slider.value / 100.0
	DATA.music_volume = music_slider.value / 100.0
	DATA.sound_volume = sound_slider.value / 100.0
	
	$"../.."._fix_music_volume()
	
	$"../.."._play_sound("click")

func _save_config(_ignore):
	DATA.master_volume = master_slider.value / 100.0
	DATA.music_volume = music_slider.value / 100.0
	DATA.sound_volume = sound_slider.value / 100.0
	$"../.."._config_save_stuff()
	$"../.."._fix_music_volume()

func _close():
	$"../.."._play_sound("click")
	
	animation_player.play("slide_out")
	$"..".are_buttons_legal = true
	await animation_player.animation_finished
	print_rich("[color=violet]die")
	
	queue_free()
