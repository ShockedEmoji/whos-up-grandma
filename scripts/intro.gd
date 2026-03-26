extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	animation_player.play("intro")
	await animation_player.animation_finished
	
	DATA.root._play_music("grandma_house")
	DATA.root._fade_transition("top_down/grandma_house", 0.1, 0.1, 0.1)
	DATA.post_transition_player_pos = Vector2(354.0, 286.0)
