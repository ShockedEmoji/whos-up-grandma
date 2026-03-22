extends Node

var master_volume: float = 0.8
var music_volume: float = 0.8
var sound_volume: float = 0.8

var seed_sauce: String = "mitosis bowling"

var player_frozen: bool = false

var post_transition_player_pos: Vector2 = Vector2.ZERO

var rng = RandomNumberGenerator.new()



var bee_triggered: bool = false
var bee_just_killed: bool = false




func _rand(extra_thing: String):
	rng.seed = hash(seed_sauce + extra_thing)
	
	return(rng.randi())


var save_file = "user://save_data.spinglespongle"

#func _save_data():
	#var data_file = FileAccess.open(save_file, FileAccess.WRITE)
	#
	#var output: String = ""
	#
	#if data_file:
		#output += str(markers_held)
		#print("Data saved! It's this thing -----> " + output)
		#data_file.store_string(output)
	#else:
		#printerr("CAN'T FIND THE DATA FILE AAAAAHAHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH (this is where it should be: " + str(save_file) + ")")

func _load_save_file():
	var save_file_real = FileAccess.open(save_file, FileAccess.READ)
	
	if save_file_real:
		var content: String = save_file_real.get_as_text() 
		
		print(content)
		
		save_file_real.close()
		
	else:
		printerr("YOU HAVE NOTHING TO LOAD")
