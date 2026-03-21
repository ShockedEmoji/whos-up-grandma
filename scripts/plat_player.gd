extends CharacterBody2D


const SPEED = 400.0
const JUMP_VELOCITY = -700.0

@onready var coyote: Timer = $coyote

var touched_floor_recently: bool = true

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		coyote.start(0.0)
	
	# Handle jump.
	if Input.is_action_just_pressed("confirm") and coyote.time_left > 0:
		velocity.y = JUMP_VELOCITY
		coyote.stop()
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()
