extends Node2D

var open: bool = false
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@onready var static_body_2d: StaticBody2D = $StaticBody2D

@onready var area_2d: Area2D = $Area2D

var penetrated_by_player: bool = false
@export var locked_dialogue: String
@export var open_dialogue: String

var player_node: CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite_2d.play("closed")
	area_2d.body_entered.connect(_body_entered)
	area_2d.body_exited.connect(_body_exited)

func _body_entered(body) -> void:
	if body.name == "player":
		player_node = body
		print("hey you can interact!")
		penetrated_by_player = true

func _body_exited(body) -> void:
	if body.name == "player":
		print("hey you can  not  interact!")
		penetrated_by_player = false

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("confirm") && penetrated_by_player:
		if !DATA.player_frozen:
			DATA.player_frozen = true
			print("dialogue!!")
			if !open:
				sprite_2d.play("closed")
				$"../../Camera2D/text_system"._say_dialogue(locked_dialogue)
			else:
				sprite_2d.play("open")
				$"../../Camera2D/text_system"._say_dialogue(open_dialogue)
				static_body_2d.queue_free()
				area_2d.queue_free()
			
			$"../.."._set_voice("default")
