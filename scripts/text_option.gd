extends Control

@onready var label: Label = $Label

var text_system: Node2D

var text_to_show: String = "uh oh text is broken"

func _ready():
	label.text = text_to_show
