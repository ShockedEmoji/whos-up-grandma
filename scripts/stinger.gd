extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.position = Vector2(856.0, 350.0)
	await get_tree().create_timer(5).timeout
	self.queue_free()

var speed: float = 600

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.position += Vector2.LEFT * speed * delta
