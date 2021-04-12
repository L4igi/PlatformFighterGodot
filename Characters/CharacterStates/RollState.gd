extends State

class_name RollState

func setup(change_state, animationPlayer, character, bufferedInput = null, bufferedAnimation= null):
	.setup(change_state, animationPlayer, character, bufferedInput, bufferedAnimation)
	character.jumpCount = 0

func manage_buffered_input():
	match bufferedInput: 
		character.right:
			play_animation("roll")
		character.left:
			play_animation("roll")
	manage_buffered_input_ground()
	bufferedInput = null
	
func handle_input():
	pass

func handle_input_disabled():
	buffer_input()
	
func _physics_process(_delta):
	if !stateDone:
		handle_input_disabled()
		check_stop_area_entered()
		character.velocity = character.move_and_slide(character.velocity)
		