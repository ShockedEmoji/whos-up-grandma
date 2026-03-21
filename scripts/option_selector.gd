extends Node2D

var how_many_options: int = 5
var selected_option: int = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	self.position = Vector2(710, 70 + selected_option * 100)
	
	if Input.is_action_just_pressed("up"): selected_option -= 1
	if Input.is_action_just_pressed("down"): selected_option += 1
	
	if selected_option < 0: selected_option += how_many_options
	selected_option %= how_many_options
	
	if Input.is_action_just_pressed("confirm"):
		print("yay fake")
		$".."._option_selected(selected_option)
		self.queue_free()
