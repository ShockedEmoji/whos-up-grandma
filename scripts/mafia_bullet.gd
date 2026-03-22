extends Area2D

@export var start_position: Vector2

@export var speed: float = 350
var direction: Vector2 = Vector2.ZERO
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hazard: Area2D = $hazard

var big_daddy: Node2D = null

func _ready() -> void:
	self.position = start_position
	
	self.rotation = direction.angle()
	
	hazard.big_daddy = self.big_daddy

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
