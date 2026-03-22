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
		await get_tree().create_timer(1.0).timeout
		touching_legal = true



func _ready() -> void:
	_new_attack()

var tween: Tween

var arena_bottom_left: Vector2 = Vector2(92, 479)
var arena_top_right: Vector2 = Vector2(1054, 47)

func _new_attack():
	match boss_state:
		BOSS_STATES.IDLE:
			animated_sprite_2d.play("idle")
			await get_tree().create_timer(randf_range(1.5, 3.0)).timeout
			
			var next_attack: BOSS_STATES = 2  as BOSS_STATES # randi_range(1, 3) as BOSS_STATES
			
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
			
			while (bounces < 5):
				boss.position += direction_to_player * 500 * get_process_delta_time()
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
			
			for i in range(6):
				for j in range(4):
					var inst = MAFIA_BULLET.instantiate()
					inst.start_position = boss.position
					inst.direction = Vector2.from_angle((PI * j + PI / i) / 4 * PI - 2 * PI)
					
					$"..".add_child(inst)
					
					inst.hazard.big_daddy = self
				await get_tree().create_timer(0.5).timeout
			
			boss_state = BOSS_STATES.IDLE
			pass
		BOSS_STATES.SHOOTING:
			print("shoot")
			boss_state = BOSS_STATES.IDLE
			pass
	
	_new_attack()

@onready var camera_2d: Camera2D = $Camera2D

func _death():
	$".."._stop_music()
	get_tree().paused = true
	await camera_2d._death()
	$".."._play_music("mafia fight")


enum BOSS_STATES {
	IDLE,
	LAUNCHING,
	JUMPING,
	SHOOTING
}
