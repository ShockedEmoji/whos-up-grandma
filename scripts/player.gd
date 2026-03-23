extends CharacterBody2D


const SPEED = 3000.0 # 300

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	self.position = DATA.post_transition_player_pos
	DATA.player_frozen = false

func _physics_process(_delta: float) -> void:
	
	var direction: DIR
	
	if !DATA.player_frozen:
		if Input.is_action_pressed("left"):
			velocity.x = -SPEED
			direction = DIR.LEFT
		elif Input.is_action_pressed("right"):
			velocity.x = SPEED
			direction = DIR.RIGHT
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED / 3)
		
		if Input.is_action_pressed("up"):
			velocity.y = -SPEED
			direction = DIR.UP
		elif Input.is_action_pressed("down"):
			velocity.y = SPEED
			direction = DIR.DOWN
		else:
			velocity.y = move_toward(velocity.y, 0, SPEED / 3)
		
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


enum DIR {
	NOTHING,
	LEFT,
	RIGHT,
	UP,
	DOWN
}
