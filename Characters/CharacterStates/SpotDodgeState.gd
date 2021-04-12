extends State

class_name SpotDodgeState

func _ready():
	play_animation("spotdodge")
#	create_invincibility_timer()

func setup(change_state, animationPlayer, character, bufferedInput = null, bufferedAnimation= null):
	.setup(change_state, animationPlayer, character, bufferedInput, bufferedAnimation)

func handle_input():
	pass

func handle_input_disabled():
	buffer_input()

func _physics_process(delta):
	if !stateDone:
		if character.disableInput:
			handle_input_disabled()