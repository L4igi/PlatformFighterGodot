extends State

class_name SpecialGround

var landingLagTimer = null
var airGroundMoveTransition = false

func _ready():
	landingLagTimer = create_timer("on_landingLag_timeout", "LandingLagTimer")
	character.currentHitBox = 1
	if character.moveAirGroundTransition.has(character.currentAttack):
		if character.moveAirGroundTransition.get(character.currentAttack): 
			airGroundMoveTransition = true
		else: 
			airGroundMoveTransition = false
			if character.applyLandingLag:
				create_landingLag_timer(character.applyLandingLag)
				character.applyLandingLag = null
				
				
func setup(change_state, animationPlayer, character):
	.setup(change_state, animationPlayer, character)

func _physics_process(_delta):
	if !stateDone && !hitlagTimer.get_time_left():
		handle_input_disabled()
		if character.disableInput:
			process_movement_physics(_delta)
			if check_in_air():
				if character.moveGroundAirTransition.has(character.currentAttack):
					character.change_state(GlobalVariables.CharacterState.ATTACKAIR)
					return 
				else:
					character.change_state(GlobalVariables.CharacterState.AIR)
			if airGroundMoveTransition:
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
#			initialize_superarmour()
#			manage_disabled_inputDI()
	
	
func mario():
	print("in parent mario")
	

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
