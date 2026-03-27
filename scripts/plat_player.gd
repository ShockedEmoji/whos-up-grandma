extends CharacterBody2D


const SPEED = 400.0 
const JUMP_VELOCITY = -600.0

var gravity = 1500

@onready var coyote: Timer = $coyote
@onready var variable_jump: Timer = $variable_jump
@onready var shoot: Timer = $shoot
@onready var input_buffer: Timer = $input_buffer

var touched_floor_recently: bool = true
const BULLET = preload("uid://cxi0ncap5jkgi")
const DAMAGE_PARTICLES = preload("uid://da3flgkgmdqof")
@onready var sprite: AnimatedSprite2D = $Sprite2D

var last_x: int = 1

var next_anim: String = "idle"

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		if velocity.y < 0: velocity.y += gravity * delta * (-velocity.y / 400)
		velocity.y += gravity * delta
	else:
		coyote.start(0.0)
	
	if Input.is_action_just_pressed("confirm"):
		input_buffer.start()
	
	if Input.is_action_just_released("confirm"):
		input_buffer.stop()
	
	# Handle jump.
	if input_buffer.time_left > 0 and coyote.time_left > 0:
		variable_jump.start(0.0)
		DATA.root._play_sound("jump")
		coyote.stop()
		input_buffer.stop()
	
	if Input.is_action_just_released("confirm"):
		if variable_jump.time_left > 0: velocity.y = -150
		variable_jump.stop()
	
	if Input.is_action_pressed("cancel"):
		if shoot.time_left <= 0:
			shoot.start(0.0)
			var inst = BULLET.instantiate()
			inst.start_position = self.position
			
			DATA.root._play_sound("shoot")
			
			var bullet_x: int = last_x
			var bullet_y: int = 0
			if Input.is_action_pressed("up"): bullet_y -= 1
			if Input.is_action_pressed("down"): bullet_y += 1
			
			if Input.is_action_pressed("up") && !Input.is_action_pressed("left") && !Input.is_action_pressed("right"):
				bullet_x = 0
			
			inst.direction = Vector2(bullet_x, bullet_y)
			inst.direction = inst.direction.normalized()
			
			$"..".add_child(inst)
	
	if variable_jump.time_left > 0:
		velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if velocity.x < 0: last_x = -1
	elif velocity.x > 0: last_x = 1
	
	velocity.x += x_velocity_add * 80
	x_velocity_add = move_toward(x_velocity_add, 0, 1)
	
	if velocity.x > 0: sprite.flip_h = false
	if velocity.x < 0: sprite.flip_h = true
	
	if is_on_floor():
		if velocity.x == 0: next_anim = "idle"
		else: next_anim = "walk"
	else:
		if velocity.y < -200: next_anim = "jump"
		elif velocity.y > 200: next_anim = "fall"
		else: next_anim = "air"
	
	sprite.play(next_anim)
	
	move_and_slide()



var x_velocity_add: float = 0

func _take_damage():
	print("ouchie")
	DATA.root._play_sound("damage")
	
	var inst = DAMAGE_PARTICLES.instantiate()
	inst.position = self.position
	inst.emitting = true
	$"..".add_child(inst)
	
	x_velocity_add = -10
	velocity.y = -700
	
	await inst.finished
	
	inst.queue_free()

func _die():
	self.z_index = 999
	
	sprite.play("die")
	
	sprite.flip_h = false
