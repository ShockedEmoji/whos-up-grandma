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
	WIGGLING,
	SHOOTING,
	FALLING_SKY_THINGS,
	EDGE,
	DEAD
}
