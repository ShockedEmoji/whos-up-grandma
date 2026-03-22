extends Area2D

@export var start_position: Vector2

var speed: float = 1000
var direction: Vector2 = Vector2.ZERO
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	self.position = start_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.position += direction * speed * delta
	if self.position.x > 1200 || self.position.x < -80: self.queue_free()
	if self.position.y > 1200 || self.position.y < -80: self.queue_free()


var dying: bool = false

func _die():
	dying = true
	direction = Vector2.ZERO
	animated_sprite_2d.play("break")
	await animated_sprite_2d.animation_finished
	self.queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is StaticBody2D && !dying:
		_die()


func _on_area_entered(area: Area2D) -> void:
	if area.get_parent().name == "boss" && !dying: 
		$".."._reduce_boss_health()
		_die()
