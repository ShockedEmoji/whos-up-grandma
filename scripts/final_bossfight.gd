extends Node2D

@onready var bee: Node2D = $boss
@onready var bee_anim_player: AnimationPlayer = $boss/AnimationPlayer
@onready var sprite_2d: AnimatedSprite2D = $boss/Sprite2D

const FLOWER = preload("uid://0382nyekm4jf")
const STINGER = preload("uid://dr6jodmev1wbi")
const GOOP = preload("uid://3071pwnomwdy")
@onready var player: CharacterBody2D = $player

@onready var health: AnimatedSprite2D = $health
@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar

var bullet_damage: int = 8 # set it to like 5 or something


var touching_legal: bool = true
@onready var animation_player: AnimationPlayer = $Camera2D/AnimationPlayer

@onready var camera_2d: Camera2D = $Camera2D

@onready var text_system: Node2D = $text_system/text_system


func _ready() -> void:
	get_tree().paused = false
	bee.hide()
	bee.position = Vector2(9999, 9999)
	text_system.current_voice = "bee"
	await text_system._say_dialogue("final fight intro")
	
	$".."._play_music("final fight")
	
	bee.show()
	
	bee_anim_player.play("intro")
	await bee_anim_player.animation_finished
	_new_attack()

func _death():
	$".."._stop_music()
	get_tree().paused = true
	await camera_2d._death()
	$".."._play_music("bee buzz")

func _reduce_health():
	if touching_legal:
		health._reduce_health()
		touching_legal = false
		player._take_damage()
		await get_tree().create_timer(3.0).timeout
		touching_legal = true

var dying: bool = false

func _reduce_boss_health():
	print("boss health reduced")
	texture_progress_bar.value -= bullet_damage


var boss_state = BOSS_STATES.IDLE

var arena_bottom_left: Vector2 = Vector2(100, 557)
var arena_top_right: Vector2 = Vector2(1050, 59)

var tween: Tween
var enraged: bool = false


func _new_attack():
	match boss_state:
		BOSS_STATES.IDLE:
			sprite_2d.play("idle")
			if texture_progress_bar.value <= 0:
				boss_state = BOSS_STATES.DEAD
			else:
				bee_anim_player.play("idle")
				
				await bee_anim_player.animation_finished
				
				if texture_progress_bar.value <= 500 && !enraged:
					enraged = true
					bee.modulate = "ff255f"
				
				if !enraged:
					boss_state = randi_range(1, 5) as BOSS_STATES
				else:
					boss_state = randi_range(2, 5) as BOSS_STATES
					if boss_state == BOSS_STATES.NEEDLE:
						boss_state = BOSS_STATES.SPITTING
			
			_new_attack()
			
		BOSS_STATES.SPITTING:
			sprite_2d.play("pain")
			
			if !enraged:
				bee_anim_player.play("easy spit")
				
				await get_tree().create_timer(0.8).timeout
				for i in range(4):
					sprite_2d.play("shoot")
					var inst = GOOP.instantiate()
					inst.start_position = bee.position + Vector2(-30, 5)
					inst.scale = Vector2.ONE * 0.5
					self.add_child(inst)
					DATA.root._play_sound("splurge")
					await get_tree().create_timer(3.2 / 4.0).timeout
			else:
				bee_anim_player.play("spit")
				
				await get_tree().create_timer(0.8).timeout
				for i in range(4):
					sprite_2d.play("shoot")
					var inst = GOOP.instantiate()
					inst.start_position = bee.position + Vector2(-30, 5)
					inst.scale = Vector2.ONE * 0.5
					self.add_child(inst)
					DATA.root._play_sound("splurge")
					await get_tree().create_timer(1.4 / 4.0).timeout
			sprite_2d.play("idle")
			
			await bee_anim_player.animation_finished
			
			boss_state = BOSS_STATES.IDLE
			
			_new_attack()
		BOSS_STATES.NEEDLE:
			bee_anim_player.play("stinger")
			sprite_2d.play("pain")
			await get_tree().create_timer(1.0).timeout
			for i in range(25):
				var inst = STINGER.instantiate()
				inst.start_position = bee.position + Vector2.DOWN * 50
				self.add_child(inst)
				await get_tree().create_timer(0.05).timeout
			
			await get_tree().create_timer(1.0).timeout
			
			for i in range(25):
				var inst = STINGER.instantiate()
				inst.start_position = bee.position
				self.add_child(inst)
				await get_tree().create_timer(0.05).timeout
			
			await bee_anim_player.animation_finished
			
			boss_state = BOSS_STATES.IDLE
			
			_new_attack()
		BOSS_STATES.FLOWER:
			bee_anim_player.play("flower")
			sprite_2d.play("idle")
			await get_tree().create_timer(1.25).timeout
			if !enraged:
				for i in range(30):
					await get_tree().create_timer(0.15).timeout
					var inst = FLOWER.instantiate()
					self.add_child(inst)
			else:
				for i in range(40):
					await get_tree().create_timer(0.09).timeout
					var inst = FLOWER.instantiate()
					self.add_child(inst)
			
			await bee_anim_player.animation_finished
			
			boss_state = BOSS_STATES.IDLE
			
			_new_attack()
		BOSS_STATES.LAUNCH:
			sprite_2d.play("idle")
			var direction_to_player: Vector2 = (player.position - bee.position).normalized()
			
			tween = create_tween()
			
			tween.tween_property(bee, "rotation", 3 * TAU + direction_to_player.angle(), 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			await tween.finished
			
			sprite_2d.play("pain")
			
			var bounces: int = 0
			
			while (bounces < 8):
				if !enraged:
					bee.position += direction_to_player * (500 + bounces * 30) * get_process_delta_time()
				else:
					bee.position += direction_to_player * (700 + bounces * 50) * get_process_delta_time()
				bee.rotation = direction_to_player.angle()
				
				if bee.position.y > arena_bottom_left.y: 
					direction_to_player.y = abs(direction_to_player.y) * -1
					bounces += 1
				if bee.position.y < arena_top_right.y: 
					direction_to_player.y = abs(direction_to_player.y)
					bounces += 1
				if bee.position.x < arena_bottom_left.x: 
					direction_to_player.x = abs(direction_to_player.x)
					bounces += 1
				if bee.position.x > arena_top_right.x: 
					direction_to_player.x = abs(direction_to_player.x) * -1
					bounces += 1
				
				await get_tree().process_frame
			
			tween = create_tween()
			
			tween.tween_property(bee, "position", Vector2(bee.position.x, -100), 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
			await tween.finished
			
			tween = create_tween()
			
			bee.rotation = 0
			bee.position.x = 997
			
			tween.tween_property(bee, "position:y", 449, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
			await tween.finished
			
			boss_state = BOSS_STATES.IDLE
			_new_attack()
		BOSS_STATES.BULLET_SPIRAL:
			bee_anim_player.play("bullet spiral")
			
			sprite_2d.play("idle")
			
			await get_tree().create_timer(2.0).timeout
			sprite_2d.play("pain")
			if !enraged:
				for i in range(5):
					DATA.root._play_sound("splurge")
					for j in range(6):
						var inst = GOOP.instantiate()
						inst.start_position = bee.position
						inst.scale = Vector2.ONE * 0.5
						inst.speed = 300
						
						inst.move_direction = Vector2.RIGHT.rotated(j * TAU / 6 + i * PI / 12)
						
						self.add_child(inst)
					
					await get_tree().create_timer(1.0).timeout
			else:
				for i in range(10):
					DATA.root._play_sound("splurge")
					for j in range(6):
						var inst = GOOP.instantiate()
						inst.start_position = bee.position
						inst.scale = Vector2.ONE * 0.5
						inst.speed = 450
						
						inst.move_direction = Vector2.RIGHT.rotated(j * TAU / 6 + i * PI / 12)
						
						self.add_child(inst)
					
					await get_tree().create_timer(0.5).timeout
			
			await bee_anim_player.animation_finished
			
			boss_state = BOSS_STATES.IDLE
			_new_attack()
			
		BOSS_STATES.DEAD:
			touching_legal = false
			dying = true
			
			$".."._stop_music()
			
			bee_anim_player.stop()
			bee_anim_player.play("death")
			sprite_2d.play("pain")
			await get_tree().create_timer(4.0).timeout
			DATA.root._play_sound("oh honey")
			await bee_anim_player.animation_finished
			
			DATA.post_transition_player_pos = Vector2(14470.0, 1572)
			DATA.final_bee_just_killed = true
			$".."._stop_music()
			$".."._fade_transition("top_down/final_area", 0.2, 0, 3, $Camera2D)

var npc_to_shut_up: AnimatedSprite2D = null

@warning_ignore("unused_signal")
signal dialogue_finished

func _say_dialogue(dialogue: String, npc: AnimatedSprite2D) -> void:
	text_system.current_voice = "bee"
	text_system._say_dialogue(dialogue)
	
	npc_to_shut_up = npc

func _shut_up_npc():
	if npc_to_shut_up != null:
		npc_to_shut_up.play("idle")
		npc_to_shut_up = null


enum BOSS_STATES {
	IDLE,
	SPITTING,
	NEEDLE,
	FLOWER,
	LAUNCH,
	BULLET_SPIRAL,
	DEAD
}
