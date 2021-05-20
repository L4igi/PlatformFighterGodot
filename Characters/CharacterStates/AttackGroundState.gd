extends State

class_name AttackGroundState
#landinglag
var landingLagTimer = null
var smashAttackMultiplierTimer = null
var smashAttackMultiplierFrames = 60.0
var smashAttackHoldFrames = 1800.0
#var smashAttackHoldFrames = 180.0
var shiftDegrees = 10.0
var rotateSmashAttackDegrees = 0.0

func _ready():
	landingLagTimer = Globals.create_timer("on_landingLag_timeout", "LandingLagTimer", self)
	smashAttackMultiplierTimer = Globals.create_timer("on_smashAttackMultiplier_timeout", "SmashAttackMultiplierTimer", self)
	character.currentHitBox = 1
	if !character.airGroundMoveTransition: 
		if character.applyLandingLag:
			create_landingLag_timer(character.applyLandingLag)
			character.applyLandingLag = null
#	else:
#		if character.bufferInvincibilityFrames > 0:
#			create_invincibility_timer(character.bufferInvincibilityFrames)
#			character.bufferInvincibilityFrames = 0


func setup(change_state, transitionBufferedInput, animationPlayer, character):
	.setup(change_state, transitionBufferedInput, animationPlayer, character)
	character.airTime = 0
	character.disabledEdgeGrab = false
	character.jumpCount = 0
	character.airdodgeAvailable = true
	character.smashAttackMultiplier = 1.0
	bufferedInput = character.moveTransitionBufferedInput
	rotateSmashAttackDegrees = 0.0

func switch_to_current_state_again(transitionBufferedInput):
	character.damagePercentArmour = 0.0
	character.knockbackArmour = 0.0
	character.multiHitArmour = 0.0
	rotateSmashAttackDegrees = 0.0
	.switch_to_current_state_again(transitionBufferedInput)

func manage_transition_buffered_input():
	if character.grabbedItem: 
		attack_handler_ground_throw_attack()
		transitionBufferedInput = null 
		return
	match transitionBufferedInput:
		Globals.CharacterAnimations.SHORTHOPATTACK:
			process_shorthop_attack()
		Globals.CharacterAnimations.JAB1:
			if Input.is_action_pressed(character.jump):
				process_shorthop_attack()
			else:
				character.currentAttack = Globals.CharacterAnimations.JAB1
				jab_handler()
		Globals.CharacterAnimations.JAB2:
			if Input.is_action_pressed(character.jump):
				process_shorthop_attack()
			else:
				character.currentAttack = Globals.CharacterAnimations.JAB2
				jab_handler()
		Globals.CharacterAnimations.JAB3:
			if Input.is_action_pressed(character.jump):
				process_shorthop_attack()
			else:
				character.currentAttack = Globals.CharacterAnimations.JAB3
				jab_handler()
		Globals.CharacterAnimations.DSMASH:
			if Input.is_action_pressed(character.jump):
				process_shorthop_attack()
			else:
				character.smashAttack = transitionBufferedInput
				character.currentAttack = Globals.CharacterAnimations.DSMASH
				attack_handler_ground_smash_attacks()
		Globals.CharacterAnimations.UPSMASH:
			if Input.is_action_pressed(character.jump):
				process_shorthop_attack()
			else:
				character.smashAttack = transitionBufferedInput
				character.currentAttack = Globals.CharacterAnimations.UPSMASH
				attack_handler_ground_smash_attacks()
		Globals.CharacterAnimations.FSMASHL:
			if Input.is_action_pressed(character.jump):
				process_shorthop_attack()
			else:
				character.smashAttack = transitionBufferedInput
				character.currentAttack = Globals.CharacterAnimations.FSMASH
				attack_handler_ground_smash_attacks()
		Globals.CharacterAnimations.FSMASHR:
			if Input.is_action_pressed(character.jump):
				process_shorthop_attack()
			else:
				character.smashAttack = transitionBufferedInput
				character.currentAttack = Globals.CharacterAnimations.FSMASH
				attack_handler_ground_smash_attacks()
		Globals.CharacterAnimations.UPTILT:
			if Input.is_action_pressed(character.jump):
				process_shorthop_attack()
			else:
				character.currentAttack = Globals.CharacterAnimations.UPTILT
				play_attack_animation("uptilt")
		Globals.CharacterAnimations.DTILT:
			if Input.is_action_pressed(character.jump):
				process_shorthop_attack()
			else:
				character.currentAttack = Globals.CharacterAnimations.DTILT
				play_attack_animation("dtilt")
		Globals.CharacterAnimations.FTILTL:
			if Input.is_action_pressed(character.jump):
				process_shorthop_attack()
			else:
				if character.currentMoveDirection != Globals.MoveDirection.LEFT:
					character.currentMoveDirection = Globals.MoveDirection.LEFT
					character.mirror_areas()
				character.currentAttack = Globals.CharacterAnimations.FTILT
				shift_attack_angle()
				play_attack_animation("ftilt")
		Globals.CharacterAnimations.FTILTR:
			if Input.is_action_pressed(character.jump):
				process_shorthop_attack()
			else:
				if character.currentMoveDirection != Globals.MoveDirection.RIGHT:
					character.currentMoveDirection = Globals.MoveDirection.RIGHT
					character.mirror_areas()
				character.currentAttack = Globals.CharacterAnimations.FTILT
				shift_attack_angle()
				play_attack_animation("ftilt")
	transitionBufferedInput = null
				
func manage_buffered_input():
	.manage_buffered_input_ground()
	initialize_superarmour()
	character.disableInputDI = manage_disabled_inputDI()
	bufferedInput = null

func _physics_process(_delta):
	if !stateDone && !hitlagTimer.get_time_left():
		if !landingLagTimer.get_time_left() && transitionBufferedInput:
			manage_transition_buffered_input()
			return
		handle_input_disabled(_delta)
		if character.disableInput:
			check_stop_area_entered(_delta)
			process_movement_physics(_delta)
			if check_in_air():
				if character.moveGroundAirTransition.has(character.currentAttack):
					character.bufferInvincibilityFrames = invincibilityTimer.get_time_left()
					character.change_state(Globals.CharacterState.AIR)
					return
				else:
					character.disableInput = false
					character.change_state(Globals.CharacterState.AIR)
					return
#			if character.airGroundMoveTransition:
#				manage_air_ground_move_transition()
			if !landingLagTimer.get_time_left():
				if character.chargingSmashAttack:
#					check_stop_area_entered(_delta)
					shift_attack_angle()
					if (Input.is_action_just_released(character.attack)\
					|| !Input.is_action_pressed(character.attack)):
						calculate_smash_multiplier()
						character.chargingSmashAttack = false
						character.smashAttack = null
						character.animatedSprite.set_rotation_degrees(rotateSmashAttackDegrees)
						character.apply_smash_attack_steps(2)
#				if character.currentAttack == Globals.CharacterAnimations.DASHATTACK:
#					check_stop_area_entered(_delta)
				if character.currentAttack == Globals.CharacterAnimations.JAB1\
				|| character.currentAttack == Globals.CharacterAnimations.JAB2\
				|| character.currentAttack == Globals.CharacterAnimations.JAB3:
					if character.comboNextJab:
						if Input.is_action_pressed(character.attack)\
						&& get_input_direction_x() == 0\
						&& get_input_direction_y() == 0:
							animationPlayer.stop()
							jab_handler()
							character.comboNextJab = false
				elif character.multiPartSmashAttack.has(character.currentAttack):
					if character.comboNextSmash == true:
						if character.currentPartSmashAttack < character.multiPartSmashAttack.get(character.currentAttack):
							if Input.is_action_just_pressed(character.attack):
								character.currentPartSmashAttack += 1
								multipart_smashAttack_handler()
		else:
			if character.grabbedItem: 
				attack_handler_ground_throw_attack()
			elif character.smashAttack != null: 
				attack_handler_ground_smash_attacks()
			elif (abs(get_input_direction_x()) == 0 || character.jabCount > 0) \
			&& get_input_direction_y() == 0:
				jab_handler()
			elif get_input_direction_y() < 0:
				character.currentAttack = Globals.CharacterAnimations.UPTILT
				play_attack_animation("uptilt")
			elif get_input_direction_y() > 0:
				character.currentAttack = Globals.CharacterAnimations.DTILT
				play_attack_animation("dtilt")
			elif character.currentMaxSpeed == character.baseWalkMaxSpeed: 
				if character.currentMoveDirection == Globals.MoveDirection.LEFT:
					character.currentAttack = Globals.CharacterAnimations.FTILT
					shift_attack_angle()
					play_attack_animation("ftilt")
				elif character.currentMoveDirection == Globals.MoveDirection.RIGHT:
					character.currentAttack = Globals.CharacterAnimations.FTILT
					shift_attack_angle()
					play_attack_animation("ftilt")
			elif character.currentMaxSpeed == character.baseRunMaxSpeed: 
				#dash attack
				match character.currentMoveDirection:
					Globals.MoveDirection.LEFT:
						character.velocity.x = -character.dashAttackSpeed
					Globals.MoveDirection.RIGHT:
						character.velocity.x = character.dashAttackSpeed
				character.currentAttack = Globals.CharacterAnimations.DASHATTACK
				play_attack_animation("dash_attack")
			initialize_superarmour()
			manage_disabled_inputDI()
			
func attack_handler_ground_smash_attacks():
	create_smashAttackMultiplier_timer(smashAttackHoldFrames)
	if character.turnAroundSmashAttack:
		match character.currentMoveDirection:
			Globals.MoveDirection.RIGHT:
				character.velocity.x = 600
			Globals.MoveDirection.LEFT:
				character.velocity.x = -600
	else:
		character.velocity = Vector2.ZERO
	character.turnAroundSmashAttack = false
	var animationToPlay = null
	match character.smashAttack: 
		Globals.CharacterAnimations.UPSMASH:
			animationToPlay = "upsmash"
			character.currentAttack = Globals.CharacterAnimations.UPSMASH
		Globals.CharacterAnimations.DSMASH:
			animationToPlay = "dsmash"
			character.currentAttack = Globals.CharacterAnimations.DSMASH
		Globals.CharacterAnimations.FSMASHR:
			if character.currentMoveDirection != Globals.MoveDirection.RIGHT:
				character.currentMoveDirection = Globals.MoveDirection.RIGHT
				character.mirror_areas()
			animationToPlay = "fsmash"
			character.currentAttack = Globals.CharacterAnimations.FSMASH
		Globals.CharacterAnimations.FSMASHL:
			if character.currentMoveDirection != Globals.MoveDirection.LEFT:
				character.currentMoveDirection = Globals.MoveDirection.LEFT
				character.mirror_areas()
			animationToPlay = "fsmash"
			character.currentAttack = Globals.CharacterAnimations.FSMASH
	play_attack_animation(animationToPlay)
			
			
func jab_handler():
	character.comboNextJab = false
	match character.jabCount:
		0:
			character.currentAttack = Globals.CharacterAnimations.JAB1
			play_attack_animation("jab1")
		1:
			character.currentAttack = Globals.CharacterAnimations.JAB2
			play_attack_animation("jab2")
		2:
			character.currentAttack = Globals.CharacterAnimations.JAB3
			play_attack_animation("jab3")
	character.jabCount += 1
	if character.jabCount > character.jabCombo: 
		character.jabCount = 0
		
func multipart_smashAttack_handler():
	character.comboNextSmash = false
	match character.currentPartSmashAttack:
		1:
			match character.currentAttack:
				Globals.CharacterAnimations.UPSMASH:
					character.currentAttack = Globals.CharacterAnimations.UPSMASH1
					play_attack_animation("upsmash1")
				Globals.CharacterAnimations.DSMASH:
					character.currentAttack = Globals.CharacterAnimations.DSMASH1
					play_attack_animation("dsmash1")
				Globals.CharacterAnimations.FSMASH:
					character.currentAttack = Globals.CharacterAnimations.FSMASH1
					play_attack_animation("fsmash1")
		2:
			match character.currentAttack:
				Globals.CharacterAnimations.UPSMASH:
					character.currentAttack = Globals.CharacterAnimations.UPSMASH2
					play_attack_animation("upsmash2")
				Globals.CharacterAnimations.DSMASH:
					character.currentAttack = Globals.CharacterAnimations.DSMASH2
					play_attack_animation("dsmash2")
				Globals.CharacterAnimations.FSMASH:
					character.currentAttack = Globals.CharacterAnimations.FSMASH2
					play_attack_animation("fsmash2")
		3:
			match character.currentAttack:
				Globals.CharacterAnimations.UPSMASH:
					character.currentAttack = Globals.CharacterAnimations.UPSMASH3
					play_attack_animation("upsmash3")
				Globals.CharacterAnimations.DSMASH:
					character.currentAttack = Globals.CharacterAnimations.DSMASH3
					play_attack_animation("dsmash3")
				Globals.CharacterAnimations.FSMASH:
					character.currentAttack = Globals.CharacterAnimations.FSMASH3
					play_attack_animation("fsmash3")
		
func handle_input(_delta):
	pass
	
func handle_input_disabled(_delta):
	var animationFramesLeft = int((animationPlayer.get_current_animation_length()-animationPlayer.get_current_animation_position())*60)
	if animationFramesLeft <= character.bufferInputWindow\
	&& !shortHopTimer.get_time_left()\
	&& bufferedInput == null: 
		.buffer_input()
		
func check_character_crouch():
	if get_input_direction_y() >= 0.5 && !inMovementLag:
		for i in character.get_slide_count():
			var collision = character.get_slide_collision(i)
			if collision.get_collider().is_in_group("Platform"):
				character.change_state(Globals.CharacterState.CROUCH)
				return true
			elif collision.get_collider().is_in_group("Ground"):
				character.change_state(Globals.CharacterState.CROUCH)
				return true
	elif get_input_direction_y() >= 0.5 && !character.bufferedSmashAttack:
		character.change_state(Globals.CharacterState.CROUCH)
		return true
	return false

	
					
func create_landingLag_timer(waitTime):
	character.gravity = character.baseGravity
	inLandingLag = true
	character.disableInput = true
	character.disableInputDI = false
	Globals.start_timer(landingLagTimer, waitTime)
	
func on_landingLag_timeout():
	inLandingLag = false
#	if !bufferedInput:
#		character.applySideStepFrames = true
#		character.change_state(Globals.CharacterState.GROUND)
#	enable_player_input()
	
	
func check_stop_area_entered(_delta):
	match character.atPlatformEdge:
		Globals.MoveDirection.RIGHT:
			match character.currentMoveDirection:
				Globals.MoveDirection.LEFT:
					character.velocity.x = 0
				Globals.MoveDirection.RIGHT:
					character.velocity.x = 0
		Globals.MoveDirection.LEFT:
			match character.currentMoveDirection:
				Globals.MoveDirection.LEFT:
					character.velocity.x = 0
				Globals.MoveDirection.RIGHT:
					character.velocity.x = 0

func create_smashAttackMultiplier_timer(waitTime):
	Globals.start_timer(smashAttackMultiplierTimer, waitTime)
	
func calculate_smash_multiplier():
	var framesLeft = smashAttackHoldFrames - smashAttackMultiplierTimer.get_time_left()*60.0
	character.smashAttackMultiplier = clamp(1.0+0.4/60.0*framesLeft, 1.0, 1.4) 

func on_smashAttackMultiplier_timeout():
	character.smashAttackMultiplier = 1.4
	character.chargingSmashAttack = false
	character.smashAttack = null
	character.animatedSprite.set_rotation_degrees(rotateSmashAttackDegrees)
	character.apply_smash_attack_steps(2)

func shift_attack_angle():
	if character.currentAttack == Globals.CharacterAnimations.FSMASH\
	|| character.currentAttack == Globals.CharacterAnimations.FTILT:
		var direction = Vector2(get_input_direction_x(),get_input_direction_y())
		var angle = rad2deg(direction.angle())
		if angle <= -15.0: 
			angle = -15.0
		elif angle >= 15.0:
			angle = 15.0
		else: angle = 0.0
		rotateSmashAttackDegrees = angle

func attack_handler_ground_throw_attack():
	if character.thrownFromGrabbedItemSpawnMove:
		character.thrownFromGrabbedItemSpawnMove = false
		character.currentAttack = Globals.CharacterAnimations.THROWITEMFORWARD
		play_attack_animation("throw_item_forward")
	elif (abs(get_input_direction_x()) == 0) \
	&& get_input_direction_y() == 0:
		character.currentAttack = Globals.CharacterAnimations.THROWITEMFORWARD
		play_attack_animation("throw_item_forward")
	elif get_input_direction_y() < 0:
		character.currentAttack = Globals.CharacterAnimations.THROWITEMUP
		play_attack_animation("throw_item_up")
	elif get_input_direction_y() > 0:
		character.currentAttack = Globals.CharacterAnimations.THROWITEMDOWN
		play_attack_animation("throw_item_down")
	elif character.currentMoveDirection == Globals.MoveDirection.LEFT:
		character.currentAttack = Globals.CharacterAnimations.THROWITEMFORWARD
		play_attack_animation("throw_item_forward")
	elif character.currentMoveDirection == Globals.MoveDirection.RIGHT:
		character.currentAttack = Globals.CharacterAnimations.THROWITEMFORWARD
		play_attack_animation("throw_item_forward")
