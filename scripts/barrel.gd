extends Node2D

var lifetime: float
var where_to_send_player: Vector2 = Vector2.ZERO

var barrel_direction: Vector2

var speed: float = 200

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if lifetime > 0:
		self.position += speed * delta * barrel_direction
		lifetime -= delta
	else: self.queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":
		body._teleport_to(where_to_send_player)
