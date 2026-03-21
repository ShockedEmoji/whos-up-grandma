extends Camera2D

@onready var player: CharacterBody2D = $"../player"
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var move_yes: int = 0

func _death():
	await get_tree().create_timer(1.0).timeout
	animation_player.play("zoom")
	move_yes = 1

func _process(delta: float) -> void:
	self.position += (player.position - self.position) * delta * 2 * move_yes
