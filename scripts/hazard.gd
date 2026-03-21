extends Area2D

@export var big_daddy: Node2D = null

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		if big_daddy != null:
			big_daddy._reduce_health()
		else:
			$"../.."._reduce_health()
