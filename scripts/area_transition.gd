extends Node2D

@export var new_area_scene_path: String
@export var camera_node: Camera2D
@export var fade_in: float = 0.5
@export var fade_hold: float = 0.0
@export var fade_out: float = 0.5
@export var new_song: String = "none"
@export_category("player stuff")
@export var new_player_position: Vector2

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		DATA.player_frozen = true
		DATA.post_transition_player_pos = new_player_position
		if new_song != "none":
			$"../../.."._play_music("grandma_house")
		$"../../.."._fade_transition(new_area_scene_path, fade_in, fade_hold, fade_out, camera_node)
