extends Node2D

@onready var rotation_amount = randf_range(-PI, PI)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.position = Vector2(randi_range(100, 1100), -100)
	
	await get_tree().create_timer(5).timeout
	self.queue_free()

var fall_y: float = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	self.rotation += rotation_amount * delta
	fall_y += delta * 8
	self.position += Vector2.DOWN * fall_y
