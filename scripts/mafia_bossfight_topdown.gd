extends Node2D

@onready var boss: Node2D = $boss
@onready var sprite_2d: AnimatedSprite2D = $boss/Sprite2D

@onready var player: CharacterBody2D = $player

@onready var health: AnimatedSprite2D = $health
@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar

var bullet_damage: int = 10 # set it to like 5 or something


var touching_legal: bool = true
@onready var animation_player: AnimationPlayer = $Camera2D/AnimationPlayer

@onready var camera_2d: Camera2D = $Camera2D

@onready var text_system: Node2D = $text_system/text_system


func _ready() -> void:
	get_tree().paused = false
	boss.position = Vector2(895, -569)
	await text_system._say_dialogue("mafia fight intro")
	
	$".."._play_music("mafia fight")
	
	tween = create_tween()
	
	tween.tween_property(boss, "position", corners[3], 1.0)
	
	await tween.finished
	
	_new_attack()
	timer.timeout.connect(_spawn_barrel)
	timer.start()

func _death():
	$".."._stop_music()
	get_tree().paused = true
	await camera_2d._death()

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

var corners: Array = [Vector2(553, 236), Vector2(895, 236), Vector2(553, 578), Vector2(895, 578)]

var tween: Tween

var sprite_anim_thingy_before: String = ""

const WATER_DROP = preload("uid://d2jmp3plcdvs2")
const BARREL_PROJECTILE = preload("uid://br4kcvx2ft70a")

var attacks_since_last_jump: int = 0
@onready var timer: Timer = $Timer

func _spawn_barrel():
	var inst = BARREL_PROJECTILE.instantiate()
	
	var barrel_pos: int = randi_range(1, 6)
	
	if barrel_pos <= 3:
		inst.move_direction = Vector2.DOWN
		inst.start_position = Vector2(380 + (barrel_pos - 1) * 342, -100)
	else:
		var rand_one_or_minus_one = randi_range(0, 1)
		if rand_one_or_minus_one == 0: rand_one_or_minus_one = - 1
		inst.move_direction = Vector2.RIGHT * rand_one_or_minus_one
		inst.start_position.y = 66 + 340 * (barrel_pos - 4)
		
		if rand_one_or_minus_one == 1: inst.start_position.x = -80
		else: inst.start_position.x = 1515
	
	inst.speed = 200
	
	self.add_child(inst)


func _new_attack():
	match boss_state:
		BOSS_STATES.IDLE:
			
			if texture_progress_bar.value <= 0:
				boss_state = BOSS_STATES.DEAD
			else:
				sprite_2d.play("idle")
				
				if attacks_since_last_jump >= 2: 
					boss_state = BOSS_STATES.JUMPING
					attacks_since_last_jump = 0
				else: 
					boss_state = randi_range(2, 4) as BOSS_STATES
					attacks_since_last_jump += 1
				await get_tree().create_timer(1.0).timeout
			
			_new_attack()
			
		BOSS_STATES.JUMPING:
			sprite_2d.play("jump")
			
			var target_pos: Vector2 = corners.get(randi_range(0, 3))
			
			tween = create_tween()
			
			tween.tween_property(boss, "position:x", target_pos.x, 2.0).set_trans(Tween.TRANS_LINEAR)
			
			tween.parallel().tween_property(
				boss, "position:y",
				target_pos.y - 300,
				1.0
			).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
			await get_tree().create_timer(1.0).timeout
			tween = create_tween()
			tween.tween_property(
				boss, "position:y",
				target_pos.y,
				1.0
			).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
			
			await tween.finished
			
			sprite_2d.play("idle")
			
			boss_state = BOSS_STATES.IDLE
			_new_attack()
			
		BOSS_STATES.FIREWORK:
			sprite_2d.play("flexing")
			await get_tree().create_timer(1.0).timeout
			for j in range(randi_range(3, 8)):
				for i in range(8):
					var inst = WATER_DROP.instantiate()
					inst.start_position = boss.position
					inst.move_direction = Vector2.from_angle(PI / 4 * i + j * PI / 8)
					inst.speed = 300
					
					inst.scale = Vector2.ONE * 0.5
					
					self.add_child(inst)
				
				DATA.root._play_sound("splash")
				
				await get_tree().create_timer(0.5).timeout
			
			await get_tree().create_timer(1.0).timeout
			
			sprite_2d.play("idle")
			
			boss_state = BOSS_STATES.IDLE
			_new_attack()
		BOSS_STATES.SPINNY_FIREWORK:
			sprite_2d.play("flexing")
			await get_tree().create_timer(1.0).timeout
			
			var which_dir: int = randi_range(0, 1)
			if which_dir == 0: which_dir = -1
			
			for j in range(randi_range(7, 15)):
				for i in range(8):
					var inst = WATER_DROP.instantiate()
					inst.start_position = boss.position
					inst.move_direction = Vector2.from_angle(PI / 4 * i + (j * PI / 32) * which_dir)
					inst.speed = 300
					
					inst.scale = Vector2.ONE * 0.5
					
					self.add_child(inst)
				
				DATA.root._play_sound("splash")
				
				await get_tree().create_timer(0.4).timeout
			
			await get_tree().create_timer(1.0).timeout
			
			sprite_2d.play("idle")
			
			boss_state = BOSS_STATES.IDLE
			_new_attack()
		BOSS_STATES.BULLET_STREAM:
			sprite_2d.play("flexing")
			await get_tree().create_timer(1.0).timeout
			for j in range(randi_range(8, 16)):
				var inst = WATER_DROP.instantiate()
				inst.start_position = boss.position
				inst.move_direction = (player.position - boss.position).normalized()
				inst.speed = 300
				
				inst.scale = Vector2.ONE * 0.5
				
				self.add_child(inst)
				
				DATA.root._play_sound("splash")
				
				await get_tree().create_timer(0.3).timeout
			
			await get_tree().create_timer(1.0).timeout
			
			sprite_2d.play("idle")
			
			boss_state = BOSS_STATES.IDLE
			_new_attack()
		BOSS_STATES.DEAD:
			touching_legal = false
			dying = true
			
			timer.stop()
			
			$".."._stop_music()
			
			sprite_2d.play("idle")
			await get_tree().create_timer(1.0).timeout
			await text_system._say_dialogue("mafia defeat")
			
			DATA.post_transition_player_pos = Vector2(168, -32)
			$".."._play_music("school")
			$".."._fade_transition("top_down/school", 0.5, 1.0, 0.5, $Camera2D)

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


enum BOSS_STATES {
	IDLE,
	JUMPING,
	FIREWORK,
	SPINNY_FIREWORK,
	BULLET_STREAM,
	DEAD
}
