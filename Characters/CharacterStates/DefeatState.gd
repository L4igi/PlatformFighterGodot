extends State

class_name DefeatState


func _ready():
	character.set_process(false)
	Globals.check_game_set()
	
func setup(change_state, transitionBufferedInput, animationPlayer, character):
	.setup(change_state, transitionBufferedInput, animationPlayer, character)
	character.reset_all()
