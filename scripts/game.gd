extends Node2D

@onready var text_system: Node2D = $Camera2D/text_system

var npc_to_shut_up: AnimatedSprite2D = null

@warning_ignore("unused_signal")
signal dialogue_finished

func _say_dialogue(dialogue: String, npc: AnimatedSprite2D = null) -> void:
	text_system._say_dialogue(dialogue)
	
	print(dialogue)
	
	if npc != null:
		npc_to_shut_up = npc

func _shut_up_npc():
	if npc_to_shut_up != null:
		npc_to_shut_up.play("idle")
		npc_to_shut_up = null
