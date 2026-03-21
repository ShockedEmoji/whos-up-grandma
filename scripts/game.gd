extends Node2D

@onready var text_system: Node2D = $Camera2D/text_system

var npc_to_shut_up: AnimatedSprite2D = null

func _say_dialogue(dialogue: String, npc: AnimatedSprite2D) -> void:
	text_system._say_dialogue(dialogue)
	
	npc_to_shut_up = npc

func _shut_up_npc():
	npc_to_shut_up.play("idle")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
