extends State

class_name ShieldState

func _ready():
	character.characterShield.enable_shield()
	#todo shield animation does not play
	play_animation("shield")
	
func setup(change_state, transitionBufferedInput, animationPlayer, character):
	.setup(change_state, transitionBufferedInput, animationPlayer, character)
	character.airdodgeAvailable = true

			
func handle_input(_delta):
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
			character.mirror_areas()
		character.rollType = character.left
		character.change_state(GlobalVariables.CharacterState.ROLL)
	elif Input.is_action_just_pressed(character.right):
		character.characterShield.disable_shield()
		if character.currentMoveDirection != GlobalVariables.MoveDirection.LEFT:
			character.currentMoveDirection = GlobalVariables.MoveDirection.LEFT
			character.mirror_areas()
		character.rollType = character.right
		character.change_state(GlobalVariables.CharacterState.ROLL)
	elif Input.is_action_just_pressed(character.down):
		character.velocity.x = 0
		character.characterShield.disable_shield()
		character.change_state(GlobalVariables.CharacterState.SPOTDODGE)

func handle_input_disabled(_delta):
	if !shortHopTimer.get_time_left():
		buffer_input()
			
func _physics_process(_delta):
	if !stateDone:
		check_stop_area_entered(_delta)
		if !character.onSolidGround:
			if check_in_air():
				character.disableInput = false
				character.bufferMoveAirTransition = true
				character.change_state(GlobalVariables.CharacterState.AIR)
		if character.disableInput:
			handle_input_disabled(_delta)
		if !character.disableInput:
			process_movement_physics(_delta)
		if !hitlagAttackedTimer.get_time_left():
			handle_input(_delta)
			if !Input.is_action_pressed(character.shield) && character.characterShield.enableShieldFrames == 0:
				character.characterShield.disable_shield()
				character.shieldDropped = true
				character.change_state(GlobalVariables.CharacterState.GROUND)

func check_stop_area_entered(_delta):
	match character.atPlatformEdge:
		GlobalVariables.MoveDirection.RIGHT:
			match character.currentMoveDirection:
				GlobalVariables.MoveDirection.LEFT:
					pass
				GlobalVariables.MoveDirection.RIGHT:
					character.velocity.x = 0
		GlobalVariables.MoveDirection.LEFT:
			match character.currentMoveDirection:
				GlobalVariables.MoveDirection.LEFT:
					character.velocity.x = 0
				GlobalVariables.MoveDirection.RIGHT:
					pass
