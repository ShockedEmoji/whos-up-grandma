extends AnimatedSprite2D

var health: int = 3

func _reduce_health():
	health -= 1
	
	play(str(health))
	
	if health <= 0:
		$".."._death()

var time: float = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta
	
	self.rotation = sin(time * 2) / 8
