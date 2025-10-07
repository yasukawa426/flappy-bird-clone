extends CharacterBody2D

##Gravity speed
@export var GRAVITY: int = 1000 

##Max up/down speed
@export var MAX_VEL: int = 600

#Speed gained when flaping
@export var FLAP_SPEED: int = -500

#will be flying okay, falling if hits a pipe
var flying: bool = false
var falling: bool = false

const START_POS = Vector2(100, 400)



func _ready() -> void:
	reset()
	
func reset():
	falling = false
	flying = false
	position = START_POS
	set_rotation(0)
	velocity = Vector2(0, 0)
	




func _physics_process(delta: float) -> void:
	#if flying or falling will always be affected by gravity
	if flying or falling:
		velocity.y += GRAVITY * delta
		
		#limits to maximum falling velocity
		if velocity.y > MAX_VEL:
			velocity.y = MAX_VEL
		
	
	#rotates the character acordingly
	if flying:
		set_rotation(deg_to_rad(velocity.y * 0.05))
		$AnimatedSprite2D.play()
	
	#rotates down
	elif falling:
		set_rotation(PI/2)
		$AnimatedSprite2D.stop()
		
	#its always moving
	move_and_collide(velocity * delta)
	position.y = clampi(position.y, 20, 760)
	
	
func flap():
	velocity.y = FLAP_SPEED
	
