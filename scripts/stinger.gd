extends Node2D

@export var start_position: Vector2
@export var slow_at_start: bool = false

var speed: float = 600

@export var move_direction: Vector2 = Vector2.LEFT


func _ready() -> void:
	
	if slow_at_start:
		var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
		audio_stream_player_2d.volume_linear = DATA.master_volume * DATA.sound_volume
		print(DATA.master_volume * DATA.sound_volume)
	
	self.position = start_position
	if slow_at_start: 
		var real_speed = speed
		speed = 50
		
		await get_tree().create_timer(3.0).timeout
		
		speed = real_speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.rotation = PI + move_direction.angle()
	self.position += move_direction * speed * delta
	if self.position.x < -500 || self.position.y > 2000: self.queue_free()

var tween: Tween

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is StaticBody2D:
		move_direction = Vector2.ZERO
		tween = create_tween()
		
		tween.tween_property(self, "modulate:a", 0, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		await tween.finished
		
		self.queue_free()
