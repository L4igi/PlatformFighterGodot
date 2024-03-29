extends KinematicBody2D


onready var stopAreaRight = $StopAreas/StopAreaRight
onready var stopAreaLeft = $StopAreas/StopAreaLeft
onready var edgeAreaLeft = $EdgeSnapLeft
onready var edgeAreaRight = $EdgeSnapRight
onready var checkYPoint = $CheckYPoint
var collidingBodies = []

var respawnPositions = [Vector2(200, -1000), Vector2(300, -1000), Vector2(400,-1000), Vector2(500, -1000)]

# Called when the node enters the scene tree for the first time.
func _ready():
	stopAreaRight.set_position(Vector2(440,-35))
	stopAreaLeft.set_position(Vector2(-440,-35))
	edgeAreaLeft.set_position(Vector2(-447,-15))
	edgeAreaLeft.edgeSnapDirection = "left"
	edgeAreaRight.set_position(Vector2(447,-15))
	edgeAreaRight.edgeSnapDirection = "right"
	Globals.centerStage = self

func _on_CollisionDetectionArea_body_entered(body):
	if body.is_in_group("Character"):
		collidingBodies.append(body)



func _on_CollisionDetectionArea_body_exited(body):
	if body.is_in_group("Character"):
		collidingBodies.erase(body)
		body.onSolidGround = null



