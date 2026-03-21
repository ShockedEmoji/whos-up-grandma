extends Node2D

@onready var bee: Node2D = $bee
@onready var bee_anim_player: AnimationPlayer = $bee/AnimationPlayer
@onready var sprite_2d: AnimatedSprite2D = $bee/Sprite2D

const FLOWER = preload("uid://ckeig7geaqv2a")
const STINGER = preload("uid://dl4ujoy2meqtm")

var idle_count: int = 0

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "idle":
		idle_count += 1
		
		if idle_count > 2:
			idle_count = 0
			
			var random: int = randi_range(1, 3)
			
			match random:
				1:
					bee_anim_player.play("spit")
					sprite_2d.play("idle")
					
					await get_tree().create_timer(1.25).timeout
					sprite_2d.play("shoot")
					await get_tree().create_timer(1.0/4.0).timeout
					sprite_2d.play("idle")
				2:
					bee_anim_player.play("stinger")
					sprite_2d.play("pain")
					await get_tree().create_timer(1.47).timeout
					var inst = STINGER.instantiate()
					self.add_child(inst)
					
					sprite_2d.play("naked pain")
				3:
					bee_anim_player.play("flower")
					await get_tree().create_timer(1.25).timeout
					for i in range(16):
						await get_tree().create_timer(0.25).timeout
						var inst = FLOWER.instantiate()
						self.add_child(inst)
		else:
			bee_anim_player.play("idle")
	else:
		bee_anim_player.play("idle")
		sprite_2d.play("idle")
