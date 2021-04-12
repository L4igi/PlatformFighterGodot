extends State

class_name ShieldState

func _ready():
	character.characterShield.enable_shield()
	#todo shield animation does not play
	play_animation("shield")
	
func setup(change_state, animationPlayer, character, bufferedInput = null, bufferedAnimation= null):
	.setup(change_state, animationPlayer, character, bufferedInput, bufferedAnimation)

			
func handle_input():
	if Input.is_action_just_pressed(character.jump):
		character.characterShield.disable_shield()
		bufferedInput = null
		create_shortHop_timer()
	elif Input.is_action_just_pressed(character.attack):
		character.characterShield.disable_shield()
		character.change_state(GlobalVariables.CharacterState.GRAB)
	elif Input.is_action_just_pressed(character.left):
		character.characterShield.disable_shield()
		if character.currentMoveDirection != GlobalVariables.MoveDirection.RIGHT:
			character.currentMoveDirection = GlobalVariables.MoveDirection.RIGHT
			mirror_areas()
		bufferedInput = character.left
		character.change_state(GlobalVariables.CharacterState.ROLL)
	elif Input.is_action_just_pressed(character.right):
		character.characterShield.disable_shield()
		if character.currentMoveDirection != GlobalVariables.MoveDirection.LEFT:
			character.currentMoveDirection = GlobalVariables.MoveDirection.LEFT
			mirror_areas()
		bufferedInput = character.right
		character.change_state(GlobalVariables.CharacterState.ROLL)
	elif Input.is_action_just_pressed(character.down):
		character.velocity.x = 0
		character.characterShield.disable_shield()
		character.change_state(GlobalVariables.CharacterState.SPOTDODGE)

func handle_input_disabled():
	if !shortHopTimer.get_time_left():
		buffer_input()
			
func _physics_process(_delta):
	if !stateDone:
		check_stop_area_entered()
		if !character.onSolidGround:
			check_in_air(_delta)
		if character.disableInput:
			handle_input_disabled()
		if !character.disableInput:
			process_movement_physics(_delta)
		if !hitlagAttackedTimer.get_time_left():
			handle_input()
			if !Input.is_action_pressed(character.shield) && character.characterShield.enableShieldFrames == 0:
				character.characterShield.disable_shield()
				character.shieldDropped = true
				character.change_state(GlobalVariables.CharacterState.GROUND)
