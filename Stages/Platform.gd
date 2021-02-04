extends KinematicBody2D


onready var stopAreaRight = $StopAreas/StopAreaRight
onready var stopAreaLeft = $StopAreas/StopAreaLeft
onready var collisionArea = $CollisionDetectionArea
onready var checkYPoint = $CheckYPoint
var collidingBodies = []

# Called when the node enters the scene tree for the first time.
func _ready():
	stopAreaRight.set_position(Vector2(122,-10))
	stopAreaLeft.set_position(Vector2(-122,-10))
	
func _physics_process(delta):
	for body in collidingBodies: 
		if body.onSolidGround == null: 
			if (body.lowestCheckYPoint.global_position.y <= checkYPoint.global_position.y):
				body.onSolidGround = self
				body.set_collision_mask_bit(1,true)
				
func _on_CollisionDetectionArea_body_entered(body):
	if body.is_in_group("Character") && body.velocity.y < 0:
		collidingBodies.append(body)
		body.set_collision_mask_bit(1,false)
	elif body.is_in_group("Character") && body.velocity.y >= 0:
		collidingBodies.append(body)


func _on_CollisionDetectionArea_body_exited(body):
	if body.is_in_group("Character"):
		collidingBodies.erase(body)
		body.onSolidGround = null
		body.set_collision_mask_bit(1,true)
