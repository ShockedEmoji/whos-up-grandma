extends Area2D

signal damaged
signal left

@onready var label: Label = $Label

var damaged_yet: bool = false

func _on_area_entered(area: Area2D) -> void:
	if area.name == "bullet" && !damaged_yet:
		damaged_yet = true
		damaged.emit()
		area._die()

func _leave():
	$AnimationPlayer.play("exit")
	await $AnimationPlayer.animation_finished
	left.emit()
