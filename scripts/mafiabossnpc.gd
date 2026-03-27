extends AnimatedSprite2D

@onready var area_2d: Area2D = $Area2D

var penetrated_by_player: bool = false

var player_node: CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.play("idle")
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
			self.play("talk")
			$"../.."._set_voice("default")
			$"../.."._say_dialogue("mafia intro top down", self)
			
			await $"../..".dialogue_finished
			
			
			DATA.root._fade_transition("top_down/mafia_bossfight")
