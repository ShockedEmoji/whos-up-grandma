extends Node2D

var lifetime: float
var where_to_send_player: Vector2 = Vector2.ZERO

var barrel_direction: Vector2

var speed: float = 200
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var spash: AudioStreamPlayer2D = $spash

func _ready() -> void:
	audio_stream_player_2d.volume_linear = DATA.master_volume * DATA.sound_volume
	spash.volume_linear = DATA.master_volume * DATA.sound_volume * 2

var rolling = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if rolling:
		if lifetime > 0:
			self.position += speed * delta * barrel_direction
			lifetime -= delta
		else: 
			rolling = false
			spash.play()
			var tween: Tween = create_tween()
			
			tween.tween_property(self, "modulate:a", 0, 1.0)
			
			await tween.finished
			
			self.queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":
		body._teleport_to(where_to_send_player)
