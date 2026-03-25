extends Node2D


var boss_state = BOSS_STATES.IDLE
@onready var animated_sprite_2d: AnimatedSprite2D = $boss/body/head/sprite
@onready var boss_anim_player: AnimationPlayer = $boss/AnimationPlayer
@onready var boss: Node2D = $boss
@onready var player: CharacterBody2D = $player
@onready var health: AnimatedSprite2D = $health

const MAFIA_BULLET = preload("uid://d3gg5o6nym2cu")
@onready var text_system: Node2D = $text_system/text_system


var touching_legal = true

func _reduce_health():
	if touching_legal:
		health._reduce_health()
		touching_legal = false
		player._take_damage()
		await get_tree().create_timer(3.0).timeout
		touching_legal = true



func _ready() -> void:
	get_tree().paused = false
	_new_attack()

var tween: Tween

var arena_bottom_left: Vector2 = Vector2(92, 479)
var arena_top_right: Vector2 = Vector2(1054, 47)

var boss_pos_right: Vector2 = Vector2(1231, 354)

var boss_pos_left: Vector2 = Vector2(210, 354)


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

var enraged: bool = false

var facing_left: bool = true

const NEO_BULLET = preload("uid://bcfw867um6wcu")

func _new_attack():
	
	match boss_state:
		BOSS_STATES.IDLE:
			if texture_progress_bar.value <= 0:
				boss_state = BOSS_STATES.DEAD
			else:
				animated_sprite_2d.play("idle")
				boss_anim_player.play("idle")
				
				if texture_progress_bar.value <= 500 && !enraged:
					enraged = true
				
				await boss_anim_player.animation_finished
				
				var next_attack: BOSS_STATES = randi_range(1, 7) as BOSS_STATES
				
				if texture_progress_bar.value <= 500 && !enraged:
					enraged = true
				
				boss_state = next_attack
				pass
		BOSS_STATES.SWAP:
			boss_anim_player.play("puppet_short")
			tween = create_tween()
			tween.tween_property(boss, "position:y", -500, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
			await tween.finished
			
			boss.scale.x *= -1
			
			if facing_left:
				
				tween = create_tween()
				
				boss.position.x = boss_pos_left.x
				tween.tween_property(boss, "position:y", boss_pos_left.y, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			else:
				tween = create_tween()
				
				boss.position.x = boss_pos_right.x
				tween.tween_property(boss, "position:y", boss_pos_right.y, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			
			facing_left = !facing_left
			
			await tween.finished
			
			boss_state = BOSS_STATES.IDLE
		BOSS_STATES.WIGGLING:
			
			boss_anim_player.play("Y")
			
			await get_tree().create_timer(0.8).timeout
			
			for i in range(30):
				var random_rotation_offset = randf_range(PI, -PI)
				
				for j in range(6):
					var inst = NEO_BULLET.instantiate()
					inst.start_position = boss.position
					inst.move_direction = Vector2.from_angle(TAU / 6.0 * j + random_rotation_offset)
					
					self.add_child(inst)
				await get_tree().create_timer(0.08).timeout
			
			await boss_anim_player.animation_finished
			
			boss_state = BOSS_STATES.IDLE
		BOSS_STATES.WIGGLING_2:
			
			boss_anim_player.play("Y")
			
			await get_tree().create_timer(0.8).timeout
			
			for i in range(30):
				
				for j in range(6):
					var inst = NEO_BULLET.instantiate()
					inst.start_position = boss.position
					inst.move_direction = Vector2.from_angle(TAU / 6.0 * j + i * PI / 16)
					
					self.add_child(inst)
				await get_tree().create_timer(0.08).timeout
			
			await boss_anim_player.animation_finished
			
			boss_state = BOSS_STATES.IDLE
		BOSS_STATES.WIGGLING_3:
			
			boss_anim_player.play("Y")
			
			await get_tree().create_timer(0.8).timeout
			
			for i in range(30):
				
				var random_rotation_offset = randf_range(PI, -PI)
				
				for j in range(12):
					var inst = NEO_BULLET.instantiate()
					inst.start_position = boss.position
					inst.move_direction = Vector2.from_angle(TAU / 12.0 * j + random_rotation_offset)
					
					self.add_child(inst)
				await get_tree().create_timer(0.1).timeout
			
			boss_state = BOSS_STATES.IDLE
		BOSS_STATES.SHOOTING:
			
			boss_anim_player.play("Shoot")
			
			await get_tree().create_timer(0.2).timeout
			# 150, 550
			tween = create_tween()
			tween.tween_property(boss, "position:y", 150, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			
			for i in range(10):
				
				var inst = NEO_BULLET.instantiate()
				inst.start_position = boss.position
				if facing_left: inst.move_direction = Vector2.LEFT
				else : inst.move_direction = Vector2.RIGHT
				
				self.add_child(inst)
				
				await get_tree().create_timer(0.05).timeout
			
			tween = create_tween()
			tween.tween_property(boss, "position:y", 670, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			
			for i in range(10):
				
				var inst = NEO_BULLET.instantiate()
				inst.start_position = boss.position
				if facing_left: inst.move_direction = Vector2.LEFT
				else : inst.move_direction = Vector2.RIGHT
				
				self.add_child(inst)
				
				await get_tree().create_timer(0.05).timeout
			
			tween = create_tween()
			tween.tween_property(boss, "position:y", boss_pos_left.y, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			
			for i in range(5):
				
				var inst = NEO_BULLET.instantiate()
				inst.start_position = boss.position
				if facing_left: inst.move_direction = Vector2.LEFT
				else : inst.move_direction = Vector2.RIGHT
				
				self.add_child(inst)
				
				await get_tree().create_timer(0.1).timeout
			
			await boss_anim_player.animation_finished
			
			boss_state = BOSS_STATES.IDLE
		BOSS_STATES.WOBBLE:
			boss_anim_player.play("puppet")
			tween = create_tween()
			if facing_left:
				tween.tween_property(boss, "position:x", boss_pos_left.x, 5.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			else:
				tween.tween_property(boss, "position:x", boss_pos_right.x, 5.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			
			var tween_y: Tween = create_tween()
			tween_y.tween_property(boss, "position:y", 670, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			await tween_y.finished
			tween_y = create_tween()
			tween_y.tween_property(boss, "position:y", 150, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			await tween_y.finished
			tween_y = create_tween()
			tween_y.tween_property(boss, "position:y", 670, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			await tween_y.finished
			tween_y = create_tween()
			tween_y.tween_property(boss, "position:y", 150, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			await tween_y.finished
			tween_y = create_tween()
			tween_y.tween_property(boss, "position:y", boss_pos_left.y, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			
			await tween.finished
			
			boss.scale.x *= -1
			facing_left = !facing_left
			boss_state = BOSS_STATES.IDLE
		BOSS_STATES.EDGE:
			boss_anim_player.play("puppet")
			
			var tween_y: Tween = create_tween()
			tween_y.tween_property(boss, "position:y", 100, 0.5).set_trans(Tween.TRANS_LINEAR)
			await tween_y.finished
			
			tween = create_tween()
			
			if facing_left:
				tween.tween_property(boss, "position:x", boss_pos_left.x - 150, 2.0).set_trans(Tween.TRANS_LINEAR)
			else:
				tween.tween_property(boss, "position:x", boss_pos_right.x + 150, 2.0).set_trans(Tween.TRANS_LINEAR)
			
			for i in range(25):
				var inst = NEO_BULLET.instantiate()
				inst.start_position = boss.position
				inst.move_direction = Vector2.DOWN
				
				self.add_child(inst)
				
				await get_tree().create_timer(0.05).timeout
			await get_tree().create_timer(0.75).timeout
			
			tween = create_tween()
			
			if facing_left:
				tween.tween_property(boss, "position:x", boss_pos_right.x, 2.0).set_trans(Tween.TRANS_LINEAR)
			else:
				tween.tween_property(boss, "position:x", boss_pos_left.x, 2.0).set_trans(Tween.TRANS_LINEAR)
			
			for i in range(25):
				var inst = NEO_BULLET.instantiate()
				inst.start_position = boss.position
				inst.move_direction = Vector2.DOWN
				
				self.add_child(inst)
				
				await get_tree().create_timer(0.05).timeout
			await get_tree().create_timer(0.75).timeout
			
			tween_y = create_tween()
			tween_y.tween_property(boss, "position:y", boss_pos_left.y, 0.5).set_trans(Tween.TRANS_LINEAR)
			await tween_y.finished
			
			boss_state = BOSS_STATES.IDLE
		BOSS_STATES.DEAD:
			touching_legal = false
			dying = true
			
			$".."._stop_music()
			
			boss_anim_player.play("puppet")
			boss_anim_player.play("puppet_loop")
			await get_tree().create_timer(1.0).timeout
			await text_system._say_dialogue("brendan defeat")
			
			DATA.post_transition_player_pos = Vector2(400.0, 200)
			DATA.mafia_killed = true
			$".."._play_music("waterfront")
			$".."._fade_transition("top_down/waterfront", 0.2, 0, 3, $Camera2D)
	
	_new_attack()

@onready var camera_2d: Camera2D = $Camera2D
@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar

var bullet_damage: int = 8

var dying: bool = false

func _reduce_boss_health():
	print("boss health reduced")
	texture_progress_bar.value -= bullet_damage

func _death():
	$".."._stop_music()
	get_tree().paused = true
	await camera_2d._death()
	DATA.root._play_music("mafia fight")


enum BOSS_STATES {
	IDLE,
	SWAP,
	WIGGLING,
	WIGGLING_2,
	WIGGLING_3,
	SHOOTING,
	WOBBLE,
	EDGE,
	DEAD
}
