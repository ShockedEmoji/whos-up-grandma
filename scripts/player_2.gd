extends CharacterBody2D


const SPEED = 450.0 # 300

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	DATA.player_frozen = false

var last_x: float = 1
var last_y: float = 1

func _physics_process(_delta: float) -> void:
	
	var direction: DIR
	
	if !DATA.player_frozen:
		if Input.is_action_pressed("left"):
			velocity.x = -SPEED
			direction = DIR.LEFT
			last_x = -1
		elif Input.is_action_pressed("right"):
			velocity.x = SPEED
			direction = DIR.RIGHT
			last_x = 1
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED / 3)
		
		if Input.is_action_pressed("up"):
			velocity.y = -SPEED
			direction = DIR.UP
			last_y = -1
		elif Input.is_action_pressed("down"):
			velocity.y = SPEED
			direction = DIR.DOWN
			last_y = 1 
		else:
			velocity.y = move_toward(velocity.y, 0, SPEED / 3)
		
		if velocity != Vector2.ZERO:
			last_x = velocity.x
			last_y = velocity.y
		
		if Input.is_action_pressed("cancel"):
			if shoot.time_left <= 0:
				shoot.start(0.0)
				var inst = BULLET.instantiate()
				inst.start_position = self.position
				
				DATA.root._play_sound("shoot")
				
				var bullet_x: float = last_x
				var bullet_y: float = last_y
				
				inst.direction = Vector2(bullet_x, bullet_y)
				inst.direction = inst.direction.normalized()
				
				$"..".add_child(inst)
		
		match direction:
			0:
				pass
			DIR.LEFT:
				sprite.play("left")
			DIR.RIGHT:
				sprite.play("right")
			DIR.UP:
				sprite.play("up")
			DIR.DOWN:
				sprite.play("down")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED / 20)
		velocity.y = move_toward(velocity.y, 0, SPEED / 20)
	
	move_and_slide()

@onready var shoot: Timer = $shoot

const BULLET = preload("uid://cxi0ncap5jkgi")
const DAMAGE_PARTICLES = preload("uid://da3flgkgmdqof")

func _take_damage():
	print("ouchie")
	DATA.root._play_sound("damage")
	
	var inst = DAMAGE_PARTICLES.instantiate()
	inst.position = self.position
	inst.emitting = true
	$"..".add_child(inst)
	
	await inst.finished
	
	inst.queue_free()



enum DIR {
	NOTHING,
	LEFT,
	RIGHT,
	UP,
	DOWN
}
