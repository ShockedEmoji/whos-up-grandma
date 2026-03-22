extends Node2D

@onready var play_button: Button = $play_button
@onready var settings_button: Button = $settings_button
@onready var quit_button: Button = $quit_button

var are_buttons_legal: bool = true

func _ready() -> void:
	play_button.pressed.connect(_load_game)
	settings_button.pressed.connect(_load_settings)
	quit_button.pressed.connect(_close_game)
	
	$".."._play_music("menu")

func _load_game():
	if are_buttons_legal:
		are_buttons_legal = false
		$".."._play_music("grandma_house")
		$".."._fade_transition("top_down/grandma_house", 0.1, 0.1, 0.1)
		DATA.post_transition_player_pos = Vector2(354.0, 286.0)


var settings_path = preload("res://scenes/menu/settings.tscn")

func _load_settings():
	if are_buttons_legal:
		are_buttons_legal = false
		print_rich("[color=cyan]Literally settings-ing it rn... and by 'it' let's just say.... my femboy")
		
		var inst = settings_path.instantiate()
		self.add_child(inst)


func _close_game():
	if are_buttons_legal:
		get_tree().quit()
