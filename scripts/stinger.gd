extends Node2D

@export var start_position: Vector2

var speed: float = 600

@export var move_direction: Vector2 = Vector2.LEFT

func _ready() -> void:
	self.position = start_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.rotation = PI + move_direction.angle()
	self.position += move_direction * speed * delta
	if self.position.x < -500 || self.position.y > 2000: self.queue_free()

var tween: Tween

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is StaticBody2D:
		move_direction = Vector2.ZERO
		tween = create_tween()
		
		tween.tween_property(self, "modulate:a", 0, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		await tween.finished
		
		self.queue_free()
