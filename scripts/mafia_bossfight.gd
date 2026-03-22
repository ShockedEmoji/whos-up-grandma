extends Node2D


var boss_state = BOSS_STATES.IDLE
@onready var animated_sprite_2d: AnimatedSprite2D = $boss/AnimatedSprite2D
@onready var boss: Node2D = $boss
@onready var player: CharacterBody2D = $player
@onready var health: AnimatedSprite2D = $health

const MAFIA_BULLET = preload("uid://d3gg5o6nym2cu")

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

var enraged: bool = false

func _new_attack():
	
	boss.position.y = arena_bottom_left.y
	
	match boss_state:
		BOSS_STATES.IDLE:
			animated_sprite_2d.play("idle")
			
			if texture_progress_bar.value <= 500 && !enraged:
				enraged = true
			
			if !enraged:
				await get_tree().create_timer(randf_range(1.0, 2.0)).timeout
			
			var next_attack: BOSS_STATES = randi_range(1, 4) as BOSS_STATES
			
			if texture_progress_bar.value <= 500 && !enraged:
				enraged = true
			
			boss_state = next_attack
			pass
		BOSS_STATES.LAUNCHING:
			print("launch")
			animated_sprite_2d.play("crouch")
			await get_tree().create_timer(0.5).timeout
			
			animated_sprite_2d.play("launch")
			
			tween = create_tween()
			
			tween.tween_property(boss, "position", Vector2(boss.position.x, 200), 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			await tween.finished
			
			var direction_to_player: Vector2 = (player.position- boss.position).normalized()
			
			var bounces: int = 0
			
			while (bounces < 8):
				if !enraged:
					boss.position += direction_to_player * (500 + bounces * 30) * get_process_delta_time()
				else:
					boss.position += direction_to_player * (600 + bounces * 50) * get_process_delta_time()
				boss.rotation = direction_to_player.angle()
				
				if boss.position.y > arena_bottom_left.y: 
					direction_to_player.y = abs(direction_to_player.y) * -1
					bounces += 1
				if boss.position.y < arena_top_right.y: 
					direction_to_player.y = abs(direction_to_player.y)
					bounces += 1
				if boss.position.x < arena_bottom_left.x: 
					direction_to_player.x = abs(direction_to_player.x)
					bounces += 1
				if boss.position.x > arena_top_right.x: 
					direction_to_player.x = abs(direction_to_player.x) * -1
					bounces += 1
				
				await get_tree().process_frame
			
			tween = create_tween()
			
			tween.tween_property(boss, "position", Vector2(boss.position.x, arena_bottom_left.y), (1000 - boss.position.y) / 800.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
			await tween.finished
			boss.rotation = 0
			
			boss_state = BOSS_STATES.IDLE
			pass
		BOSS_STATES.JUMPING:
			print("jump")
			
			animated_sprite_2d.play("crouch")
			await get_tree().create_timer(0.5).timeout
			
			var new_x = randf_range(arena_bottom_left.x, arena_top_right.x)
			
			tween = create_tween()
			
			tween.tween_property(boss, "position:x", new_x, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
			tween.parallel().tween_property(boss, "position:y", 200, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			
			await tween.finished
			
			animated_sprite_2d.play("crouch")
			await get_tree().create_timer(0.5).timeout
			
			animated_sprite_2d.play("spin")
			
			var left_or_right: int = randi_range(0, 1) 
			if left_or_right == 0: left_or_right = -1
			
			for i in range(4):
				for h in range(4):
					for j in range(4):
						var inst = MAFIA_BULLET.instantiate()
						inst.start_position = boss.position
						inst.direction = Vector2.from_angle(((j * TAU / 4) + ((i * 4 + h) * 0.1)) * left_or_right)
						
						self.add_child(inst)
						
						inst.big_daddy = self
					await get_tree().create_timer(0.2).timeout
				if !enraged:
					await get_tree().create_timer(0.8).timeout
				else:
					await get_tree().create_timer(0.4).timeout
			
			animated_sprite_2d.play("launch")
			
			tween = create_tween()
			tween.tween_property(boss, "position", Vector2(boss.position.x, arena_bottom_left.y), (1000 - boss.position.y) / 800.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
			await tween.finished
			boss.rotation = 0
			
			boss_state = BOSS_STATES.IDLE
			pass
		BOSS_STATES.SHOOTING:
			print("shoot")
			
			animated_sprite_2d.play("crouch")
			await get_tree().create_timer(0.5).timeout
			animated_sprite_2d.play("arm wave")
			
			for i in range(10):
				var left_or_right: int = int(floor(i / 2.0)) % 2
				
				var inst = MAFIA_BULLET.instantiate()
				inst.start_position = boss.position
				inst.direction = Vector2.from_angle(left_or_right * PI)
				
				inst.big_daddy = self
				
				self.add_child(inst)
				
				
				if enraged:
					inst = MAFIA_BULLET.instantiate()
					inst.start_position = boss.position
					inst.direction = Vector2.from_angle(randf_range(0, -PI))
					
					inst.big_daddy = self
					
					self.add_child(inst)
				
				
				await get_tree().create_timer(0.3).timeout
			
			boss_state = BOSS_STATES.IDLE
			pass
		BOSS_STATES.EDGE:
			animated_sprite_2d.play("crouch")
			await get_tree().create_timer(0.5).timeout
			
			tween = create_tween()
			
			var left_or_right: int = randi_range(0, 1) 
			
			var move_time: float = 1.0
			
			if enraged: move_time = 0.75
			
			match left_or_right:
				0:
					tween.tween_property(boss, "position:x", arena_bottom_left.x, move_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
				1:
					tween.tween_property(boss, "position:x", arena_top_right.x, move_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
			tween.parallel().tween_property(boss, "position:y", 200, move_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			
			await tween.finished
			
			await get_tree().create_timer(0.2).timeout
			
			animated_sprite_2d.play("launch")
			
			tween = create_tween()
			
			match left_or_right:
				0:
					tween.tween_property(boss, "position:x", arena_top_right.x - 100, move_time * 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
				1:
					tween.tween_property(boss, "position:x", arena_bottom_left.x + 100, move_time * 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
			
			for i in range(18):
				var inst = MAFIA_BULLET.instantiate()
				inst.start_position = boss.position
				inst.direction = Vector2.DOWN
				
				self.add_child(inst)
				
				inst.big_daddy = self
				await get_tree().create_timer(0.1 * move_time).timeout
			
			await get_tree().create_timer(0.5).timeout
			
			tween = create_tween()
			tween.tween_property(boss, "position", Vector2(boss.position.x, arena_bottom_left.y), (1000 - boss.position.y) / 800.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
			await tween.finished
			boss.rotation = 0
			
			boss_state = BOSS_STATES.IDLE
			pass
	
	_new_attack()

@onready var camera_2d: Camera2D = $Camera2D
@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar

var bullet_damage: int = 5

var dying: bool = false

func _reduce_boss_health():
	print("boss health reduced")
	texture_progress_bar.value -= bullet_damage
	
	if texture_progress_bar.value <= 0 && !dying:
		touching_legal = false
		dying = true
		
		boss_state = BOSS_STATES.DEAD
		
		$".."._stop_music()

func _death():
	$".."._stop_music()
	get_tree().paused = true
	await camera_2d._death()
	#".."._play_music("mafia fight")


enum BOSS_STATES {
	IDLE,
	LAUNCHING,
	JUMPING,
	SHOOTING,
	EDGE,
	DEAD
}
