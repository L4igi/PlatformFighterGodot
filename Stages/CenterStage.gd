extends KinematicBody2D


onready var stopAreaRight = $StopAreas/StopAreaRight
onready var stopAreaLeft = $StopAreas/StopAreaLeft
var collidingBodies = []

# Called when the node enters the scene tree for the first time.
func _ready():
	stopAreaRight.set_position(Vector2(445,-30))
	stopAreaLeft.set_position(Vector2(-445,-30))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_CollisisionDetectionArea_body_entered(body):
	if body.is_in_group("Character") && !collidingBodies.has(body):
		if int(body.velocity.y) >= 0:
			collidingBodies.append(body)
			body.onSolidGround = true


func _on_CollisisionDetectionArea_body_exited(body):
	if body.is_in_group("Character"):
		collidingBodies.erase(body)
		body.onSolidGround = false
