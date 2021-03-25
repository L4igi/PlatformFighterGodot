extends KinematicBody2D


onready var stopAreaRight = $StopAreas/StopAreaRight
onready var stopAreaLeft = $StopAreas/StopAreaLeft
onready var collisionArea = $CollisionDetectionArea
onready var checkYPoint = $CheckYPoint
onready var collisionEdgeDetectionLeft = $PlatformEdgeCollision/EdgeCollisionAreaLeft
onready var collisionEdgeDetectionRight = $PlatformEdgeCollision/EdgeCollisionAreaRight
var collidingBodies = []
var collidingEdgeBodies = []

# Called when the node enters the scene tree for the first time.
func _ready():
	stopAreaRight.set_position(Vector2(122,-10))
	stopAreaLeft.set_position(Vector2(-122,-10))
	collisionEdgeDetectionLeft.set_position(Vector2(-122,0))
	collisionEdgeDetectionLeft.set_scale(Vector2(1,0.8))
	collisionEdgeDetectionRight.set_position(Vector2(122,0))
	collisionEdgeDetectionRight.set_scale(Vector2(1,0.8))
	
	
func _on_CollisionDetectionArea_body_entered(body):
	if body.is_in_group("Character") && body.velocity.y < 0:
		collidingBodies.append(body)
		body.platformCollision = self
		body.set_collision_mask_bit(1,false)
	elif body.is_in_group("Character") && body.velocity.y >= 0:
		collidingBodies.append(body)
		body.platformCollision = self
	

func _on_CollisionDetectionArea_body_exited(body):
	if body.is_in_group("Character"):
		collidingBodies.erase(body)
		body.onSolidGround = null
		body.platformCollision = null
		body.set_collision_mask_bit(1,true)
		
func add_collding_edge_body(body):
	if !collidingEdgeBodies.has(body):
		collidingEdgeBodies.append(body)

func remove_colliding_edge_body(body):
	if collidingEdgeBodies.has(body):
		collidingEdgeBodies.erase(body)
