extends State

class_name AttackAirState

func _ready():
	character.currentHitBox = 1
#	if character.groundAirMoveTransition: 
#		if character.bufferInvincibilityFrames > 0:
#			create_invincibility_timer(character.bufferInvincibilityFrames)
#			character.bufferInvincibilityFrames = 0

func setup(change_state, transitionBufferedInput, animationPlayer, character):
	.setup(change_state, transitionBufferedInput, animationPlayer, character)
	character.disabledEdgeGrab = true
	character.edgeGrabShape.set_deferred("disabled", true)
	bufferedInput = character.moveTransitionBufferedInput
	
func switch_to_current_state_again(transitionBufferedInput):
	character.damagePercentArmour = 0.0
	character.knockbackArmour = 0.0
	character.multiHitArmour = 0.0
	.switch_to_current_state_again(transitionBufferedInput)
	
func manage_transition_buffered_input():
	if character.grabbedItem: 
		attack_handler_air_throw_attack()
		transitionBufferedInput = null 
		return
	match transitionBufferedInput:
		Globals.CharacterAnimations.JUMP:
			double_jump_attack_handler()
		Globals.CharacterAnimations.JAB1:
			if Input.is_action_pressed(character.jump):
				double_jump_attack_handler()
			play_attack_animation("nair")
			character.currentAttack = Globals.CharacterAnimations.NAIR
		Globals.CharacterAnimations.DSMASH:
			if Input.is_action_pressed(character.jump):
				double_jump_attack_handler()
			play_attack_animation("dair")
			character.currentAttack = Globals.CharacterAnimations.DAIR
		Globals.CharacterAnimations.UPSMASH:
			if Input.is_action_pressed(character.jump):
				double_jump_attack_handler()
			play_attack_animation("upair")
			character.currentAttack = Globals.CharacterAnimations.UPAIR
		Globals.CharacterAnimations.FSMASHL:
			if Input.is_action_pressed(character.jump):
				double_jump_attack_handler()
			if character.currentMoveDirection == Globals.MoveDirection.LEFT:
				play_attack_animation("fair")
				character.currentAttack = Globals.CharacterAnimations.FAIR
			elif character.currentMoveDirection == Globals.MoveDirection.RIGHT:
				play_attack_animation("bair")
				character.currentAttack = Globals.CharacterAnimations.BAIR
		Globals.CharacterAnimations.FSMASHR:
			if Input.is_action_pressed(character.jump):
				double_jump_attack_handler()
			if character.currentMoveDirection == Globals.MoveDirection.RIGHT:
				play_attack_animation("fair")
				character.currentAttack = Globals.CharacterAnimations.FAIR
			elif character.currentMoveDirection == Globals.MoveDirection.LEFT:
				play_attack_animation("bair")
				character.currentAttack = Globals.CharacterAnimations.BAIR
		Globals.CharacterAnimations.UPTILT:
			if Input.is_action_pressed(character.jump):
				double_jump_attack_handler()
			play_attack_animation("upair")
			character.currentAttack = Globals.CharacterAnimations.UPAIR
		Globals.CharacterAnimations.DTILT:
			if Input.is_action_pressed(character.jump):
				double_jump_attack_handler()
			play_attack_animation("dair")
			character.currentAttack = Globals.CharacterAnimations.DAIR
		Globals.CharacterAnimations.FTILTL:
			if Input.is_action_pressed(character.jump):
				double_jump_attack_handler()
			if character.currentMoveDirection == Globals.MoveDirection.LEFT:
				play_attack_animation("fair")
				character.currentAttack = Globals.CharacterAnimations.FAIR
			elif character.currentMoveDirection == Globals.MoveDirection.RIGHT:
				play_attack_animation("bair")
				character.currentAttack = Globals.CharacterAnimations.BAIR
		Globals.CharacterAnimations.FTILTR:
			if Input.is_action_pressed(character.jump):
				double_jump_attack_handler()
			if character.currentMoveDirection == Globals.MoveDirection.RIGHT:
				play_attack_animation("fair")
				character.currentAttack = Globals.CharacterAnimations.FAIR
			elif character.currentMoveDirection == Globals.MoveDirection.LEFT:
				play_attack_animation("bair")
				character.currentAttack = Globals.CharacterAnimations.BAIR
		Globals.CharacterAnimations.DASHATTACK:
			if Input.is_action_pressed(character.jump):
				double_jump_attack_handler()
			play_attack_animation("fair")
			character.currentAttack = Globals.CharacterAnimations.FAIR
	transitionBufferedInput = null
			
func manage_buffered_input():
	.manage_buffered_input_air()
	initialize_superarmour()
	character.disableInputDI = manage_disabled_inputDI()
	bufferedInput = null
	
func handle_input(_delta):
	pass

func handle_input_disabled(_delta):
	var animationFramesLeft = int((animationPlayer.get_current_animation_length()-animationPlayer.get_current_animation_position())*60)
	if animationFramesLeft <= character.bufferInputWindow\
	&& bufferedInput == null: 
		.buffer_input()
	
	
func _physics_process(_delta):
	if !stateDone:
		if transitionBufferedInput:
			manage_transition_buffered_input()
			return
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
			if character.attackData.has(Globals.CharacterAnimations.keys()[character.currentAttack] + "_neutral"):
				var currentAttackData = character.attackData[Globals.CharacterAnimations.keys()[character.currentAttack] + "_neutral"]
				character.applyLandingLag = currentAttackData["landingLag"]
			else:
				character.applyLandingLag = character.normalLandingLag
			if character.moveAirGroundTransition.has(character.currentAttack):
				character.bufferInvincibilityFrames = invincibilityTimer.get_time_left()
			character.change_state(Globals.CharacterState.GROUND)
			return
			#toggle_all_hitboxes("off")
		if character.groundAirMoveTransition:
			manage_ground_air_move_transition()
		elif !character.disableInput:
			if character.grabbedItem: 
				attack_handler_air_throw_attack()
			elif abs(get_input_direction_x()) == 0\
			&& abs(get_input_direction_y()) == 0:
				play_attack_animation("nair")
				character.currentAttack = Globals.CharacterAnimations.NAIR
			elif get_input_direction_y() < 0:
				play_attack_animation("upair")
				character.currentAttack = Globals.CharacterAnimations.UPAIR
			elif get_input_direction_x() > 0 && character.currentMoveDirection == Globals.MoveDirection.RIGHT\
			|| get_input_direction_x() < 0 && character.currentMoveDirection == Globals.MoveDirection.LEFT: 
				play_attack_animation("fair")
				character.currentAttack = Globals.CharacterAnimations.FAIR
			elif get_input_direction_x() > 0 && character.currentMoveDirection == Globals.MoveDirection.LEFT\
			|| get_input_direction_x() < 0 && character.currentMoveDirection == Globals.MoveDirection.RIGHT: 
				play_attack_animation("bair")
				character.currentAttack = Globals.CharacterAnimations.BAIR
			elif get_input_direction_y() > 0:
				play_attack_animation("dair")
				character.currentAttack = Globals.CharacterAnimations.DAIR
			initialize_superarmour()
			character.disableInputDI = manage_disabled_inputDI()
		if character.velocity.y > 0 && get_input_direction_y() >= 0.5: 
			character.set_collision_mask_bit(1,false)
		elif character.velocity.y > 0 && get_input_direction_y() < 0.5 && character.platformCollision == null && !character.platformCollisionDisabledTimer.get_time_left():
			character.set_collision_mask_bit(1,true) 
			
func manage_ground_air_move_transition():
	character.disableInput = true

func attack_handler_air_throw_attack():
	if (abs(get_input_direction_x()) == 0) \
	&& get_input_direction_y() == 0:
		character.currentAttack = Globals.CharacterAnimations.THROWITEMFORWARD
		play_attack_animation("throw_item_forward")
	elif get_input_direction_y() < 0:
		character.currentAttack = Globals.CharacterAnimations.THROWITEMUP
		play_attack_animation("throw_item_up")
	elif get_input_direction_y() > 0:
		character.currentAttack = Globals.CharacterAnimations.THROWITEMDOWN
		play_attack_animation("throw_item_down")
	elif get_input_direction_x() > 0:
		if character.currentMoveDirection == Globals.MoveDirection.LEFT:
			character.currentMoveDirection = Globals.MoveDirection.RIGHT
			character.mirror_areas()
		character.currentAttack = Globals.CharacterAnimations.THROWITEMFORWARD
		play_attack_animation("throw_item_forward")
	elif get_input_direction_x() < 0:
		if character.currentMoveDirection == Globals.MoveDirection.RIGHT:
			character.currentMoveDirection = Globals.MoveDirection.LEFT
			character.mirror_areas()
		character.currentAttack = Globals.CharacterAnimations.THROWITEMFORWARD
		play_attack_animation("throw_item_forward")
