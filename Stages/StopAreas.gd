extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_StopAreaRight_body_entered(body):
	if body.is_in_group("Character"):
		body.atPlatformEdge = GlobalVariables.MoveDirection.RIGHT
		stop_character_velocity(body)

func _on_StopAreaLeft_body_entered(body):
	if body.is_in_group("Character"):
		body.atPlatformEdge = GlobalVariables.MoveDirection.LEFT
		stop_character_velocity(body)


func stop_character_velocity(body):
	var stopCharacter = body
	stopCharacter.stopAreaEntered = true



func _on_StopAreaRight_body_exited(body):
	body.stopAreaEntered = false
	body.atPlatformEdge = null


func _on_StopAreaLeft_body_exited(body):
	body.stopAreaEntered = false
	body.atPlatformEdge = null
