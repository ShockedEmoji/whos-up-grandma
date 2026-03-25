extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var label_2: Label = $Label_2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label_2.text = ""
	
	await get_tree().create_timer(2.0).timeout
	
	label_2.text = "You may have the medicine required to save your grandma..."
	
	DATA.root._play_sound("click")
	
	await get_tree().create_timer(4.0).timeout
	
	label_2.text = "But will she ever recieve it?"
	
	DATA.root._play_sound("click")
	
	await get_tree().create_timer(4.0).timeout
	
	DATA.root._play_sound("click")
	
	label_2.text = ""
	
	await get_tree().create_timer(4.0).timeout
	
	DATA.root._play_music("credits")
	
	animation_player.play("scroll")
	
	await animation_player.animation_finished
	
	await get_tree().create_timer(3.0).timeout
	
	DATA.root._play_music("menu")
	DATA._reset_data()
	DATA.root._fade_transition("menu/main_menu")
