extends KinematicBody2D

const WALK_FORCE = 800
const WALK_MAX_SPEED = 600
const STOP_FORCE = 800
const JUMP_SPEED = 800
onready var gravity = 2000
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var velocity = Vector2()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	process_movement_physics(delta)
	
func process_movement_physics(delta):
	velocity.x = move_toward(velocity.x, 0, STOP_FORCE * delta)
	velocity.x = clamp(velocity.x, -WALK_MAX_SPEED, WALK_MAX_SPEED)
	# Vertical movement code. Apply gravity.
	velocity.y += gravity * delta
	# Move based on the velocity and snap to the ground.
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
	
func apply_force(power, direction, damage = 0):
	velocity = power*direction
	
