extends Area2D




# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_BlastZones_body_entered(body):
	if body.is_in_group("Character"):
		if body.currentState != Globals.CharacterState.DEFEAT\
		&& body.currentState != Globals.CharacterState.RESPAWN:
			if body.stocks -1 == 0:
				body.animationPlayer.stop()
				body.change_state(Globals.CharacterState.DEFEAT)
			else:
				body.animationPlayer.stop()
				body.change_state(Globals.CharacterState.RESPAWN)
