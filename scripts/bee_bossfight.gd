extends Node2D

@onready var bee: Node2D = $boss
@onready var bee_anim_player: AnimationPlayer = $boss/AnimationPlayer
@onready var sprite_2d: AnimatedSprite2D = $boss/Sprite2D

const FLOWER = preload("uid://ckeig7geaqv2a")
const STINGER = preload("uid://dl4ujoy2meqtm")
const GOOP = preload("uid://3071pwnomwdy")
@onready var player: CharacterBody2D = $player

@onready var health: AnimatedSprite2D = $health
@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar

var bullet_damage: int = 5 # set it to like 5 or something

var idle_count: int = 0

var touching_legal: bool = true
@onready var animation_player: AnimationPlayer = $Camera2D/AnimationPlayer

@onready var camera_2d: Camera2D = $Camera2D
@onready var small_bee: Area2D = $small_bee

func _ready() -> void:
	get_tree().paused = false
	bee.hide()
	bee.position = Vector2(9999, 9999)
	await text_system._say_dialogue("bee fight intro")
	
	await small_bee.damaged
	
	await text_system._say_dialogue("bee ouch")
	
	$".."._play_music("bee_fight")
	
	small_bee._leave()
	await small_bee.left
	
	bee_anim_player.animation_finished.connect(_on_animation_player_animation_finished)
	
	bee_anim_player.play("intro")
	bee.show()
	
	await bee_anim_player.animation_finished
	bee_anim_player.play("idle")

func _death():
	$".."._stop_music()
	get_tree().paused = true
	await camera_2d._death()
	$".."._play_music("tutorial")

func _reduce_health():
	if touching_legal:
		health._reduce_health()
		touching_legal = false
		player._take_damage()
		await get_tree().create_timer(1.0).timeout
		touching_legal = true

var dying: bool = false

func _reduce_boss_health():
	print("boss health reduced")
	texture_progress_bar.value -= bullet_damage
	
	if texture_progress_bar.value <= 0 && !dying:
		touching_legal = false
		dying = true
		
		$".."._stop_music()
		
		bee_anim_player.stop()
		bee_anim_player.play("death")
		sprite_2d.play("pain")
		await bee_anim_player.animation_finished
		
		DATA.post_transition_player_pos = Vector2(4471.0, -1510)
		DATA.bee_just_killed = true
		$".."._play_music("tutorial")
		$".."._fade_transition("top_down/tutorial", 0.2, 0, 3, $Camera2D)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "idle":
		idle_count += 1
		
		if idle_count > 0:
			idle_count = 0
			
			var random: int = randi_range(1, 5)
			
			match random:
				1, 2:
					bee_anim_player.play("spit")
					sprite_2d.play("idle")
					
					await get_tree().create_timer(1.25).timeout
					sprite_2d.play("shoot")
					var inst = GOOP.instantiate()
					self.add_child(inst)
					await get_tree().create_timer(1.0/4.0).timeout
					sprite_2d.play("idle")
				3, 4:
					bee_anim_player.play("stinger")
					sprite_2d.play("pain")
					await get_tree().create_timer(1.47).timeout
					var inst = STINGER.instantiate()
					self.add_child(inst)
					
					sprite_2d.play("naked pain")
				5:
					bee_anim_player.play("flower")
					await get_tree().create_timer(1.25).timeout
					for i in range(10):
						await get_tree().create_timer(0.35).timeout
						var inst = FLOWER.instantiate()
						self.add_child(inst)
		else:
			bee_anim_player.play("idle")
	elif anim_name == "death":
		pass
	else:
		bee_anim_player.play("idle")
		sprite_2d.play("idle")



@onready var text_system: Node2D = $text_system/text_system

var npc_to_shut_up: AnimatedSprite2D = null

@warning_ignore("unused_signal")
signal dialogue_finished

func _say_dialogue(dialogue: String, npc: AnimatedSprite2D) -> void:
	text_system._say_dialogue(dialogue)
	
	npc_to_shut_up = npc

func _shut_up_npc():
	if npc_to_shut_up != null:
		npc_to_shut_up.play("idle")
		npc_to_shut_up = null
