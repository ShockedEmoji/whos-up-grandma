extends Node2D

@export var barrel_interval: float = 5.0
@export var barrel_speed: float = 500
@export var barrel_life: float = 3.0
@export var player_send_back_position: Vector2 = Vector2.ZERO
@export var barrel_direction: Vector2 = Vector2.DOWN

@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.wait_time = barrel_interval
	timer.timeout.connect(_timer_timeout)
	timer.start()

const BARREL = preload("uid://dtr4xopj7h665")

func _timer_timeout() -> void:
	var inst = BARREL.instantiate()
	
	inst.lifetime = barrel_life
	inst.where_to_send_player = player_send_back_position
	inst.barrel_direction = barrel_direction
	inst.speed = barrel_speed
	
	self.add_child(inst)
