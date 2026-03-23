extends Node2D

signal anim_finished

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _play_anim(anim_name: String) -> void:
	animation_player.play(anim_name)

func _ready() -> void:
	animation_player.animation_finished.connect(anim_finished.emit)
