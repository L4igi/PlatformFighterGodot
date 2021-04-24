extends State

class_name SpecialGround

var landingLagTimer = null

func _ready():
	landingLagTimer = create_timer("on_landingLag_timeout", "LandingLagTimer")
	character.currentHitBox = 1
	if !character.airGroundMoveTransition: 
		if character.applyLandingLag:
			create_landingLag_timer(character.applyLandingLag)
			character.applyLandingLag = null
	else:
		if character.bufferInvincibilityFrames > 0:
			create_invincibility_timer(character.bufferInvincibilityFrames)
			character.bufferInvincibilityFrames = 0
#	character.check_special_animation_steps()
				
				
func setup(change_state, animationPlayer, character):
	.setup(change_state, animationPlayer, character)

func _physics_process(_delta):
	if !stateDone && !hitlagTimer.get_time_left():
		handle_input_disabled(_delta)
		if character.disableInput:
			process_movement_physics(_delta)
			if check_in_air():
				if character.moveGroundAirTransition.has(character.currentAttack):
#					character.check_special_animation_steps()
					character.bufferInvincibilityFrames = invincibilityTimer.get_time_left()
					character.change_state(GlobalVariables.CharacterState.AIR)
					return
				else:
					character.disableInput = false
					character.bufferMoveAirTransition = true
					character.change_state(GlobalVariables.CharacterState.AIR)
					return
			if character.airGroundMoveTransition:
				manage_air_ground_move_transition()
		else:
			if (abs(get_input_direction_x()) == 0 || character.jabCount > 0) \
			&& get_input_direction_y() == 0:
				character.currentAttack = GlobalVariables.CharacterAnimations.NSPECIAL
				play_attack_animation("neutralspecial")
			elif get_input_direction_y() < 0:
				character.currentAttack = GlobalVariables.CharacterAnimations.UPSPECIAL
				play_attack_animation("upspecial")
			elif get_input_direction_y() > 0:
				character.currentAttack = GlobalVariables.CharacterAnimations.DOWNSPECIAL
				play_attack_animation("downspecial")
			elif get_input_direction_x() > 0 && character.currentMoveDirection == GlobalVariables.MoveDirection.LEFT\
			|| get_input_direction_x() < 0 && character.currentMoveDirection == GlobalVariables.MoveDirection.RIGHT: 
				if character.currentMoveDirection != GlobalVariables.MoveDirection.RIGHT:
					character.currentMoveDirection = GlobalVariables.MoveDirection.RIGHT
				elif character.currentMoveDirection != GlobalVariables.MoveDirection.LEFT:
					character.currentMoveDirection = GlobalVariables.MoveDirection.LEFT
				mirror_areas()
				play_attack_animation("sidespecial")
				character.currentAttack = GlobalVariables.CharacterAnimations.SIDESPECIAL
			elif character.currentMoveDirection == GlobalVariables.MoveDirection.LEFT:
				play_attack_animation("sidespecial")
				character.currentAttack = GlobalVariables.CharacterAnimations.SIDESPECIAL
			elif character.currentMoveDirection == GlobalVariables.MoveDirection.RIGHT:
				play_attack_animation("sidespecial")
				character.currentAttack = GlobalVariables.CharacterAnimations.SIDESPECIAL
			character.initialize_special_animation_steps()
			character.disableInputDI = manage_disabled_inputDI()
#			initialize_superarmour()
#			manage_disabled_inputDI()

func manage_air_ground_move_transition():
	character.disableInput = true

func create_landingLag_timer(waitTime):
	character.gravity = character.baseGravity
	inLandingLag = true
	character.disableInput = true
	character.disableInputDI = false
	start_timer(landingLagTimer, waitTime)
	
func on_landingLag_timeout():
	inLandingLag = false
	if !bufferedInput:
		character.applySideStepFrames = true
		character.change_state(GlobalVariables.CharacterState.GROUND)
	enable_player_input()

	
