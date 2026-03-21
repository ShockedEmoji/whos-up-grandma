extends Node2D

@export var start_position: Vector2

var speed: float = 600

func _ready() -> void:
	self.position = start_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.position += Vector2.LEFT * speed * delta
	if self.position.x < -500: self.queue_free()
