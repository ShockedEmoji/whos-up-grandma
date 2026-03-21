extends Camera2D

@export var what_am_i_following: Node2D

func _ready() -> void:
	self.position = what_am_i_following.position

func _process(delta: float) -> void:
	self.position += (what_am_i_following.position - self.position) * delta * 2
