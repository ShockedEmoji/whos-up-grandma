extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player" && !DATA.bee_triggered:
		DATA.plinth_interacted = true
