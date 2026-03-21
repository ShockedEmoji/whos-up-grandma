extends CharacterBody2D


const SPEED = 400.0
const JUMP_VELOCITY = -600.0

var gravity = 1500

@onready var coyote: Timer = $coyote
@onready var variable_jump: Timer = $variable_jump

var touched_floor_recently: bool = true

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		if velocity.y < 0: velocity.y += gravity * delta * (-velocity.y / 400)
		velocity.y += gravity * delta
	else:
		coyote.start(0.0)
	
	# Handle jump.
	if Input.is_action_just_pressed("confirm") and coyote.time_left > 0:
		variable_jump.start(0.0)
		coyote.stop()
	
	if Input.is_action_just_released("confirm"):
		if variable_jump.time_left > 0: velocity.y = -150
		variable_jump.stop()
	
	if variable_jump.time_left > 0:
		velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()
