extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	DATA.root._play_music("credits")
	
	animation_player.play("scroll")
	
	await animation_player.animation_finished
	
	DATA.root._fade_transition("menu/main_menu")
