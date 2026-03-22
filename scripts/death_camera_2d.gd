extends Camera2D

@onready var player: CharacterBody2D = $"../player"
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var death_music: AudioStreamPlayer = $death_music

var move_yes: int = 0

@export var default_scene: String = "platformer/bee_bossfight"

func _death():
	await get_tree().create_timer(1.0).timeout
	animation_player.play("zoom")
	move_yes = 1
	
	death_music.volume_linear = DATA.master_volume * DATA.music_volume
	death_music.play()
	
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("confirm"):
			break
	
	death_music.stop()
	
	$"../.."._fade_transition(default_scene)

func _process(delta: float) -> void:
	self.position += (player.position - self.position) * delta * 2 * move_yes
