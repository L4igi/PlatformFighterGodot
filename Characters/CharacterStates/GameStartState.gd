extends State

class_name GameStartState

func _ready():
	play_animation("gamestart")
	play_animation("idle", true)
		
func setup(change_state, transitionBufferedInput, animationPlayer, character):
	.setup(change_state, transitionBufferedInput, animationPlayer, character)
	
	

