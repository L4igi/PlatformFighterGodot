extends State

class_name SpotDodgeState

func _ready():
	play_animation("spotdodge")
#	create_invincibility_timer()

func setup(change_state, transitionBufferedInput, animationPlayer, character):
	.setup(change_state, transitionBufferedInput, animationPlayer, character)

func manage_buffered_input():
	manage_buffered_input_ground()

func handle_input(_delta):
	pass

func handle_input_disabled(_delta):
	if !bufferedInput:
		buffer_input()

func _physics_process(_delta):
	if !stateDone:
		if character.disableInput:
			handle_input_disabled(_delta)
