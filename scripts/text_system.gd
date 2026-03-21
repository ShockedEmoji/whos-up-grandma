extends Node2D


class Piece_Of_Dialogue:
	var title: String
	var dialogue: Array
	var input_options: Array
	var input_options_pointers: Array
	
	# some other event things or something φ(゜▽゜*)♪ 

@onready var box: Node2D = $box

@onready var label: Label = $box/Label

var text_printing: bool = false

signal le_button_pressed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	box.visible = false
	
	_calculate_dialogue()
	print_rich("[color=cyan]AAAAAAAAAAAAAAAAAAAAAAHHHHHHHHHHHHHHHH")

var button_pressed_stupid_fix_later_PLEASE: bool = false

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("confirm"):
		le_button_pressed.emit()
		print("button")

const TEXT_OPTION = preload("res://scenes/top_down/text_option.tscn")
@onready var options_box: Control = $options_box

func _say_dialogue(title_name: String):
	
	if !text_printing:
		text_printing = true
		options_box.visible = false
		
		box.visible = true
		
		if title_name == "stop":
			print_rich("[color=red]TEXT DIE")
			return
		
		var selected_dialogue: Piece_Of_Dialogue = null
		
		for i in options_box.get_children():
			i.queue_free()
		
		for i: Piece_Of_Dialogue in dialogue_options_array:
			if i.title == title_name:
				selected_dialogue = i
				break
		
		if selected_dialogue == null:
			printerr("couldn't find dialogue -> " + title_name + "     text is wrong stupidf")
			return
		
		var text_list: Array = selected_dialogue.dialogue
		
		for i in text_list.size():
			await _load_text(text_list[i])
			
			await get_tree().process_frame
			
			if !text_list[i].contains("&"):
				if i != text_list.size() - 1:
					await le_button_pressed
		
		if selected_dialogue.input_options.size() > 0:
			await get_tree().process_frame
			
			while !(Input.is_action_just_pressed("confirm")):
				await get_tree().process_frame
			
			await get_tree().process_frame
			
			_load_selectable_options(selected_dialogue)
			
			text_printing = false
		else:
			await get_tree().process_frame
			
			while !(Input.is_action_just_pressed("confirm")):
				await get_tree().process_frame
			
			text_printing = false
			
			if !text_list[text_list.size() - 1].contains('['):
				DATA.player_frozen = false
			
			$"../.."._shut_up_npc()
			$"../..".dialogue_finished.emit()
			
			box.visible = false

var current_selected_dialogue

func _load_selectable_options(selected_dialogue):
	options_box.visible = true
	
	var current_options: Array
	
	for i in selected_dialogue.input_options.size():
		
		var option_inst = TEXT_OPTION.instantiate()
		option_inst.text_to_show = selected_dialogue.input_options[i]
		
		options_box.add_child(option_inst)
		
		current_options.append(option_inst)
	
	var inst = OPTION_SELECTOR.instantiate()
	inst.how_many_options = selected_dialogue.input_options.size()
	self.add_child(inst)
	
	current_selected_dialogue = selected_dialogue

const OPTION_SELECTOR = preload("uid://cgccoiie6g1d1")


func _option_selected(which_option: int):
	_say_dialogue(current_selected_dialogue.input_options_pointers[which_option])

var letter_length: float = 0.01

const letters_before_new_line: int = 73

func _load_text(text_to_load: String):
	
	# find spaces in string
	# for every letters_before_new_line characters, go back to the last space and replace it with \n
	# if no space in the last letters_before_new_line characters, add \n after space letters_before_new_line
	
	text_to_load = text_to_load.replace('[', '')
	text_to_load = text_to_load.replace('&', '')
	text_to_load = text_to_load.replace('|', '\n')
	
	print_rich("[color=lime]", text_to_load)
	
	var select_char: int = 0
	
	while (select_char + letters_before_new_line < text_to_load.length()):
		
		var ten_letter_segment: String = text_to_load.substr(select_char, letters_before_new_line)
		
		var last_new_line: int = ten_letter_segment.rfind("\n")
		var last_space: int = ten_letter_segment.rfind(" ")
		
		if last_new_line == -1:
			if last_space != -1:
				text_to_load = text_to_load.erase(select_char + last_space)
				text_to_load = text_to_load.insert(select_char + last_space, "\n")
			else:
				text_to_load = text_to_load.insert(select_char + letters_before_new_line, "\n")
		else:
			select_char += last_new_line
			print("new line found")
		
		select_char += letters_before_new_line + 1
	
	var time: float = 0.0
	var end_time: float = letter_length * (text_to_load.length() - 1)
	
	while time < end_time:
		time += get_process_delta_time()
		
		var current_text: String = ""
		for j in text_to_load.length():
			if text_to_load[j] == "\n":
				current_text += "\n"
			else:
				current_text += " "
		
		var fake_time: float = 0.0
		var current_letter: int = 0
		
		while fake_time < time && current_letter < text_to_load.length():
			fake_time += letter_length
			current_text[current_letter] = text_to_load[current_letter]
			current_letter += 1
		label.text = current_text
		
		await get_tree().process_frame
	
	label.text = text_to_load

var dialogue_options_array: Array

func _calculate_dialogue():
	var text_file = FileAccess.open("res://misc/game_text.txt", FileAccess.READ)
	var file_as_text = text_file.get_as_text().split("\n")
	
	var current_dialogue: Piece_Of_Dialogue = null
	
	for i: String in file_as_text:
		if i.begins_with("}"): # declaring new dialogue chunk
			
			if current_dialogue != null:
				dialogue_options_array.append(current_dialogue)
			
			current_dialogue = Piece_Of_Dialogue.new()
			current_dialogue.title = i.substr(1)
		elif i.begins_with("{"): # one of the choices for the player to select
			
			current_dialogue.input_options.append(i.substr(1, i.find("`") - 1)) # gets text from position 1 to position of "`"
			current_dialogue.input_options_pointers.append(i.substr(i.find("`") + 1)) # everything after the "`"
			
		else: # somewhere in the center of a dialogue thingy chunk thing
			if current_dialogue != null:
				if i != "\n" && i != "": # makes sure it's not an empty string
					var line_with_breaks = i ## IMPORTANT DO THE TEXT WRAPPING THING YOU KNOW HOW TO DO IT 🙌👌😉👍🤷‍♀️😀😃
					
					## VVVVVVVVVVV this bit is for like the funny modifiers and stuff fix it later to make it cooler and stuff < thank you for the note, please leave more notes
					#if line_with_breaks.contains("["):
						#var x_position: float = 0
						#var y_position: float = 0
						#var marker_type: int = 0
						#
						#var square_bracket_1: int = line_with_breaks.find("[")
						#var comma_between: int = line_with_breaks.find(",", square_bracket_1)
						#var square_bracket_2: int = line_with_breaks.find("]")
						#var square_bracket_3: int = line_with_breaks.find("]", square_bracket_2 + 1)
						#x_position = float(line_with_breaks.substr(square_bracket_1 + 1, comma_between - square_bracket_1 - 1))
						#y_position = float(line_with_breaks.substr(comma_between + 1, square_bracket_2 - comma_between - 1))
						#marker_type = int(line_with_breaks.substr(square_bracket_2 + 1, square_bracket_3 - square_bracket_2 - 1))
						#
						#
						#current_dialogue.marker_pos_array.append(Vector2(x_position, y_position))
						#current_dialogue.marker_type_array.append(marker_type)
						#
						#current_dialogue.tud_text.append(line_with_breaks.left(square_bracket_1) + line_with_breaks.right(2))
					#else:
					current_dialogue.dialogue.append(line_with_breaks)
	
	dialogue_options_array.append(current_dialogue) # add the last one
