extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_StopAreaRight_body_entered(body):
	if body.is_in_group("Character"):
		body.atPlatformEdge = body.moveDirection.RIGHT
		stop_character_velocity(body)

func _on_StopAreaLeft_body_entered(body):
	if body.is_in_group("Character"):
		body.atPlatformEdge = body.moveDirection.LEFT
		stop_character_velocity(body)


func stop_character_velocity(body):
	var stopCharacter = body
	if stopCharacter.get_input_direction_x() == 0\
	&& stopCharacter.currentState != stopCharacter.CharacterState.HITSTUNGROUND\
	&&stopCharacter.currentState != stopCharacter.CharacterState.HITSTUNAIR\
	|| stopCharacter.currentState == stopCharacter.CharacterState.ATTACKGROUND\
	|| stopCharacter.currentState == stopCharacter.CharacterState.GETUP\
	|| stopCharacter.currentState == stopCharacter.CharacterState.SHIELD\
	|| stopCharacter.currentState == stopCharacter.CharacterState.ROLL:
		if stopCharacter.onSolidGround: 
			if self.global_position < stopCharacter.global_position: 
				stopCharacter.velocity.x = 0
			else:
				stopCharacter.velocity.x = 0



func _on_StopAreaRight_body_exited(body):
	body.atPlatformEdge = null


func _on_StopAreaLeft_body_exited(body):
	body.atPlatformEdge = null
