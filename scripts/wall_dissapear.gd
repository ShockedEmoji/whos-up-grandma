extends Node

@export var y_position_to_dissapear: float
@export var player: CharacterBody2D

var alpha_to_achieve: int = 1

func _process(_delta: float) -> void:
	if player.position.y < y_position_to_dissapear && alpha_to_achieve == 1:
		alpha_to_achieve = 0
		_fade_away()
	elif alpha_to_achieve == 0 && player.position.y > y_position_to_dissapear:
		alpha_to_achieve = 1
		_fade_in()

func _fade_away():
	var tween: Tween = create_tween()
	
	self.z_index = 3
	
	tween.tween_property(self, "modulate:a", 0, 1.0)

func _fade_in():
	var tween: Tween = create_tween()
	
	self.z_index = -2
	
	tween.tween_property(self, "modulate:a", 1, 1.0)
