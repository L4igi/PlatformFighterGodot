extends State

class_name AttackAirState

func _ready():
	character.currentHitBox = 1
	if character.groundAirMoveTransition: 
		if character.bufferInvincibilityFrames > 0:
			create_invincibility_timer(character.bufferInvincibilityFrames)
			character.bufferInvincibilityFrames = 0

func setup(change_state, animationPlayer, character):
	.setup(change_state, animationPlayer, character)
	character.disabledEdgeGrab = true
	character.edgeGrabShape.set_deferred("disabled", true)
	
func switch_to_current_state_again():
	character.damagePercentArmour = 0.0
	character.knockbackArmour = 0.0
	character.multiHitArmour = 0.0

func manage_buffered_input():
	match bufferedInput:
		GlobalVariables.CharacterAnimations.JUMP:
			character.queueFreeFall = true
			character.currentAttack = null
			double_jump_handler()
			character.change_state(GlobalVariables.CharacterState.AIR)
		GlobalVariables.CharacterAnimations.JAB1:
			if Input.is_action_pressed(character.jump):
				double_jump_attack_handler()
			play_attack_animation("nair")
			character.currentAttack = GlobalVariables.CharacterAnimations.NAIR
		GlobalVariables.CharacterAnimations.DSMASH:
			if Input.is_action_pressed(character.jump):
				double_jump_attack_handler()
			play_attack_animation("dair")
			character.currentAttack = GlobalVariables.CharacterAnimations.DAIR
		GlobalVariables.CharacterAnimations.UPSMASH:
			if Input.is_action_pressed(character.jump):
				double_jump_attack_handler()
			play_attack_animation("upair")
			character.currentAttack = GlobalVariables.CharacterAnimations.UPAIR
		GlobalVariables.CharacterAnimations.FSMASHL:
			if Input.is_action_pressed(character.jump):
				double_jump_attack_handler()
			if character.currentMoveDirection == GlobalVariables.MoveDirection.LEFT:
				play_attack_animation("fair")
				character.currentAttack = GlobalVariables.CharacterAnimations.FAIR
			elif character.currentMoveDirection == GlobalVariables.MoveDirection.RIGHT:
				play_attack_animation("bair")
				character.currentAttack = GlobalVariables.CharacterAnimations.BAIR
		GlobalVariables.CharacterAnimations.FSMASHR:
			if Input.is_action_pressed(character.jump):
				double_jump_attack_handler()
			if character.currentMoveDirection == GlobalVariables.MoveDirection.RIGHT:
				play_attack_animation("fair")
				character.currentAttack = GlobalVariables.CharacterAnimations.FAIR
			elif character.currentMoveDirection == GlobalVariables.MoveDirection.LEFT:
				play_attack_animation("bair")
				character.currentAttack = GlobalVariables.CharacterAnimations.BAIR
		GlobalVariables.CharacterAnimations.UPTILT:
			if Input.is_action_pressed(character.jump):
				double_jump_attack_handler()
			play_attack_animation("upair")
			character.currentAttack = GlobalVariables.CharacterAnimations.UPAIR
		GlobalVariables.CharacterAnimations.DTILT:
			if Input.is_action_pressed(character.jump):
				double_jump_attack_handler()
			play_attack_animation("dair")
			character.currentAttack = GlobalVariables.CharacterAnimations.DAIR
		GlobalVariables.CharacterAnimations.FTILTL:
			if Input.is_action_pressed(character.jump):
				double_jump_attack_handler()
			if character.currentMoveDirection == GlobalVariables.MoveDirection.LEFT:
				play_attack_animation("fair")
				character.currentAttack = GlobalVariables.CharacterAnimations.FAIR
			elif character.currentMoveDirection == GlobalVariables.MoveDirection.RIGHT:
				play_attack_animation("bair")
				character.currentAttack = GlobalVariables.CharacterAnimations.BAIR
		GlobalVariables.CharacterAnimations.FTILTR:
			if Input.is_action_pressed(character.jump):
				double_jump_attack_handler()
			if character.currentMoveDirection == GlobalVariables.MoveDirection.RIGHT:
				play_attack_animation("fair")
				character.currentAttack = GlobalVariables.CharacterAnimations.FAIR
			elif character.currentMoveDirection == GlobalVariables.MoveDirection.LEFT:
				play_attack_animation("bair")
				character.currentAttack = GlobalVariables.CharacterAnimations.BAIR
		GlobalVariables.CharacterAnimations.DASHATTACK:
			if Input.is_action_pressed(character.jump):
				double_jump_attack_handler()
			play_attack_animation("fair")
			character.currentAttack = GlobalVariables.CharacterAnimations.FAIR
		_:
			character.currentAttack = null
	initialize_superarmour()
	character.disableInputDI = manage_disabled_inputDI()
	bufferedInput = null
	
func handle_input():
	pass

func handle_input_disabled(_delta):
	var animationFramesLeft = int((animationPlayer.get_current_animation_length()-animationPlayer.get_current_animation_position())*60)
	if animationFramesLeft <= character.bufferInputWindow\
	&& bufferedInput == null: 
		.buffer_input()
	
	
func _physics_process(_delta):
	if !stateDone:
		handle_input_disabled(_delta)
		if character.disableInputDI:
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
				character.bufferInvincibilityFrames = invincibilityTimer.get_time_left()
			character.change_state(GlobalVariables.CharacterState.GROUND)
			return
			#toggle_all_hitboxes("off")
		if character.groundAirMoveTransition:
			manage_ground_air_move_transition()
		elif !character.disableInput:
			if abs(get_input_direction_x()) == 0\
			&& abs(get_input_direction_y()) == 0:
				play_attack_animation("nair")
				character.currentAttack = GlobalVariables.CharacterAnimations.NAIR
			elif get_input_direction_y() < 0:
				play_attack_animation("upair")
				character.currentAttack = GlobalVariables.CharacterAnimations.UPAIR
			elif get_input_direction_x() > 0 && character.currentMoveDirection == GlobalVariables.MoveDirection.RIGHT\
			|| get_input_direction_x() < 0 && character.currentMoveDirection == GlobalVariables.MoveDirection.LEFT: 
				play_attack_animation("fair")
				character.currentAttack = GlobalVariables.CharacterAnimations.FAIR
			elif get_input_direction_x() > 0 && character.currentMoveDirection == GlobalVariables.MoveDirection.LEFT\
			|| get_input_direction_x() < 0 && character.currentMoveDirection == GlobalVariables.MoveDirection.RIGHT: 
				play_attack_animation("bair")
				character.currentAttack = GlobalVariables.CharacterAnimations.BAIR
			elif get_input_direction_y() > 0:
				play_attack_animation("dair")
				character.currentAttack = GlobalVariables.CharacterAnimations.DAIR
			initialize_superarmour()
			character.disableInputDI = manage_disabled_inputDI()
		if character.velocity.y > 0 && get_input_direction_y() >= 0.5: 
			character.set_collision_mask_bit(1,false)
		elif character.velocity.y > 0 && get_input_direction_y() < 0.5 && character.platformCollision == null && !character.platformCollisionDisabledTimer.get_time_left():
			character.set_collision_mask_bit(1,true) 
			
func manage_ground_air_move_transition():
	character.disableInput = true
