extends State

class_name RollState

func setup(change_state, animationPlayer, character, bufferedInput = null, bufferedAnimation= null):
	.setup(change_state, animationPlayer, character, bufferedInput, bufferedAnimation)
	character.jumpCount = 0
	manage_roll_animation(character.rollType)

func manage_buffered_input():
	manage_buffered_input_ground()
	
func manage_roll_animation(rollType):
	match rollType: 
		character.right:
			play_animation("roll")
		character.left:
			play_animation("roll")
	
func handle_input():
	pass

func handle_input_disabled():
	if !bufferedInput:
		.buffer_input()
	
func _physics_process(_delta):
	if !stateDone:
		handle_input_disabled()
		check_stop_area_entered(_delta)
		character.velocity = character.move_and_slide_with_snap(character.velocity, Vector2.DOWN, Vector2.UP, true)
		
