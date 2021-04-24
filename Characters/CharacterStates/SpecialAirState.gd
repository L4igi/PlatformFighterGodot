extends State

class_name SpecialAir

func _ready():
	character.currentHitBox = 1
	if character.groundAirMoveTransition: 
		if character.bufferInvincibilityFrames > 0:
			create_invincibility_timer(character.bufferInvincibilityFrames)
			character.bufferInvincibilityFrames = 0

func setup(change_state, animationPlayer, character):
	.setup(change_state, animationPlayer, character)

func _physics_process(_delta):
	if !stateDone:
		handle_input_disabled()
		if disableInputDi:
			process_disable_input_direction_influence(_delta)
		else:
			process_movement_physics_air(_delta)
		if character.airTime <= 300: 
			character.airTime += 1
		var solidGroundCollision = check_ground_platform_collision(character.platformCollisionDisabledTimer.get_time_left())
		if solidGroundCollision:
			character.onSolidGround = solidGroundCollision
			var currentAttackData = character.attackData[GlobalVariables.CharacterAnimations.keys()[character.currentAttack] + "_neutral"]
			character.applyLandingLag = currentAttackData["landingLag"]
			if character.moveAirGroundTransition.has(character.currentAttack):
				character.change_state(GlobalVariables.CharacterState.SPECIALGROUND)
			else:
				character.change_state(GlobalVariables.CharacterState.GROUND)
			return
			#toggle_all_hitboxes("off")
		if character.groundAirMoveTransition:
			manage_ground_air_move_transition()
		elif !character.disableInput:
			if abs(get_input_direction_x()) == 0\
			&& abs(get_input_direction_y()) == 0:
				play_attack_animation("neutralspecial")
				character.currentAttack = GlobalVariables.CharacterAnimations.NSPECIAL
			elif get_input_direction_y() < 0:
				play_attack_animation("upspecial")
				character.currentAttack = GlobalVariables.CharacterAnimations.UPSPECIAL
			elif get_input_direction_y() > 0:
				play_attack_animation("downspecial")
				character.currentAttack = GlobalVariables.CharacterAnimations.DOWNSPECIAL
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
#			disableInputDi = manage_disabled_inputDI()
#		if character.velocity.y > 0 && get_input_direction_y() >= 0.5: 
#			character.set_collision_mask_bit(1,false)
#		elif character.velocity.y > 0 && get_input_direction_y() < 0.5 && character.platformCollision == null && !character.platformCollisionDisabledTimer.get_time_left():
#			character.set_collision_mask_bit(1,true) 

func manage_ground_air_move_transition():
	character.disableInput = true
