extends Area2D

@onready var camera_2d: Camera2D = $"../../Camera2D"
@onready var bee_camera_marker: Marker2D = $"../bee_camera_marker"
@onready var animation_player: AnimationPlayer = $"../bee_sprite/AnimationPlayer"
@onready var text_system: Node2D = $"../../Camera2D/text_system"


func _on_body_entered(body: Node2D) -> void:
	if body.name == "player" && !DATA.bee_triggered:
		DATA.player_frozen = true
		DATA.bee_triggered = true
		camera_2d.what_am_i_following = bee_camera_marker
		
		animation_player.play("bee intro")
		await animation_player.animation_finished
		
		await get_tree().create_timer(1).timeout
		
		await text_system._say_dialogue("bee intro")
		
		await $"../..".dialogue_finished
		
		$"../../.."._fade_transition("platformer/bee_bossfight")

func _ready():
	if DATA.bee_just_killed:
		print("that bee really died 💀💀💀")
		DATA.bee_just_killed = false
		DATA.player_frozen = true
		print("that bee really died 💀💀💀 2")
		animation_player.play("bee death")
		print("that bee really died 💀💀💀 3")
		await get_tree().process_frame
		print("that bee really died 💀💀💀 4")
		$"../.."._say_dialogue("bee death")
		print("that bee really died 💀💀💀 5")
		animation_player.play("bee death last")
		print("that bee really died 💀💀💀 6")
