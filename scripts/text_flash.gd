extends Node2D

@export var text_to_display: String = "string didn't work"

@export var time_alive: float = 3.0

@onready var label: Label = $Label

func _ready() -> void:
	
	text_to_display = text_to_display.replace('|', '\n')
	label.text = text_to_display
	
	var tween: Tween = create_tween()
	
	self.modulate.a = 0
	tween.tween_property(self, "modulate:a", 1, 0.5)
	await tween.finished
	
	await get_tree().create_timer(time_alive).timeout
	
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, 0.5)
	await tween.finished
	
	self.queue_free()
