extends Area2D

@onready var camera_2d: Camera2D = $"../../Camera2D"
@onready var camera_marker: Marker2D = $"../camera_marker"
@onready var animation_player: AnimationPlayer = $"../bee_sprite/AnimationPlayer"
@onready var text_system: Node2D = $"../../Camera2D/text_system"


func _on_body_entered(body: Node2D) -> void:
	if body.name == "player" && !DATA.final_bee_triggered && DATA.plinth_interacted:
		DATA.player_frozen = true
		DATA.final_bee_triggered = true
		text_system.current_voice = "bee"
		camera_2d.what_am_i_following = camera_marker
		
		await get_tree().create_timer(1.0).timeout
		
		$"../../.."._play_music("bee buzz")
		
		animation_player.play("intro")
		await animation_player.animation_finished
		
		await get_tree().create_timer(1).timeout
		
		text_system._say_dialogue("final bee intro")
		
		await $"../..".dialogue_finished
		
		DATA.root._fade_transition("platformer/final_bossfight")

func _ready():
	if DATA.final_bee_just_killed:
		text_system.current_voice = "bee"
		print("that bee really died 💀💀💀")
		DATA.final_bee_just_killed = false
		DATA.player_frozen = true
		print("that bee really died 💀💀💀 2")
		animation_player.play("death")
		print("that bee really died 💀💀💀 3")
		await get_tree().process_frame
		print("that bee really died 💀💀💀 4")
		$"../..".text_system._say_dialogue("final bee death")
