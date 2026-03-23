extends Node2D

@onready var rotation_amount = randf_range(-PI, PI)

@export var fall_speed: int = 8

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.position = Vector2(randi_range(100, 1100), -100)

var fall_y: float = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	self.rotation += rotation_amount * delta
	fall_y += delta * fall_speed
	self.position += Vector2.DOWN * fall_y
	
	if self.position.y > 800: self.queue_free()
