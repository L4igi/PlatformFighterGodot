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
	landingLagTimer = create_timer("on_landingLag_timeout", "LandingLagTimer")
	smashAttackMultiplierTimer = create_timer("on_smashAttackMultiplier_timeout", "SmashAttackMultiplierTimer")
	character.currentHitBox = 1
	if character.applyLandingLag:
		switch_from_air_to_ground(character.applyLandingLag)
		character.applyLandingLag = null

func setup(change_state, animationPlayer, character):
	.setup(change_state, animationPlayer, character)
	character.airTime = 0
	character.disabledEdgeGrab = false
	character.jumpCount = 0
	character.airdodgeAvailable = true
	character.smashAttackMultiplier = 1.0

func switch_to_current_state_again():
	character.damagePercentArmour = 0.0
	character.knockbackArmour = 0.0
	character.multiHitArmour = 0.0

func manage_buffered_input():
	match bufferedInput:
		GlobalVariables.CharacterAnimations.SHORTHOPATTACK:
			process_shorthop_attack()
		GlobalVariables.CharacterAnimations.JUMP:
			if Input.is_action_pressed(character.attack):
				process_shorthop_attack()
			else:
				character.currentAttack = null
				bufferedInput = null
				process_jump()
				character.change_state(GlobalVariables.CharacterState.AIR)
		GlobalVariables.CharacterAnimations.JAB1:
			if Input.is_action_pressed(character.jump):
				process_shorthop_attack()
			else:
				jab_handler()
				character.currentAttack = GlobalVariables.CharacterAnimations.JAB1
		GlobalVariables.CharacterAnimations.JAB2:
			if Input.is_action_pressed(character.jump):
				process_shorthop_attack()
			else:
				jab_handler()
				character.currentAttack = GlobalVariables.CharacterAnimations.JAB2
		GlobalVariables.CharacterAnimations.JAB3:
			if Input.is_action_pressed(character.jump):
				process_shorthop_attack()
			else:
				jab_handler()
				character.currentAttack = GlobalVariables.CharacterAnimations.JAB3
		GlobalVariables.CharacterAnimations.GRAB:
			character.currentAttack = null
			bufferedInput = null
			character.change_state(GlobalVariables.CharacterState.GRAB)
		GlobalVariables.CharacterAnimations.DSMASH:
			if Input.is_action_pressed(character.jump):
				process_shorthop_attack()
			else:
				character.smashAttack = bufferedInput
				attack_handler_ground_smash_attacks()
				character.currentAttack = GlobalVariables.CharacterAnimations.DSMASH
		GlobalVariables.CharacterAnimations.UPSMASH:
			if Input.is_action_pressed(character.jump):
				process_shorthop_attack()
			else:
				character.smashAttack = bufferedInput
				attack_handler_ground_smash_attacks()
				character.currentAttack = GlobalVariables.CharacterAnimations.UPSMASH
		GlobalVariables.CharacterAnimations.FSMASHL:
			if Input.is_action_pressed(character.jump):
				process_shorthop_attack()
			else:
				character.smashAttack = bufferedInput
				attack_handler_ground_smash_attacks()
				character.currentAttack = GlobalVariables.CharacterAnimations.FSMASH
		GlobalVariables.CharacterAnimations.FSMASHR:
			if Input.is_action_pressed(character.jump):
				process_shorthop_attack()
			else:
				character.smashAttack = bufferedInput
				attack_handler_ground_smash_attacks()
				
		GlobalVariables.CharacterAnimations.UPTILT:
			if Input.is_action_pressed(character.jump):
				process_shorthop_attack()
			else:
				character.currentAttack = GlobalVariables.CharacterAnimations.UPTILT
				play_attack_animation("uptilt")
		GlobalVariables.CharacterAnimations.DTILT:
			if Input.is_action_pressed(character.jump):
				process_shorthop_attack()
			else:
				character.currentAttack = GlobalVariables.CharacterAnimations.DTILT
				play_attack_animation("dtilt")
		GlobalVariables.CharacterAnimations.FTILTL:
			if Input.is_action_pressed(character.jump):
				process_shorthop_attack()
			else:
				if character.currentMoveDirection != GlobalVariables.MoveDirection.LEFT:
					character.currentMoveDirection = GlobalVariables.MoveDirection.LEFT
					mirror_areas()
				character.currentAttack = GlobalVariables.CharacterAnimations.FTILT
				shift_attack_angle()
				play_attack_animation("ftilt")
		GlobalVariables.CharacterAnimations.FTILTR:
			if Input.is_action_pressed(character.jump):
				process_shorthop_attack()
			else:
				if character.currentMoveDirection != GlobalVariables.MoveDirection.RIGHT:
					character.currentMoveDirection = GlobalVariables.MoveDirection.RIGHT
					mirror_areas()
				character.currentAttack = GlobalVariables.CharacterAnimations.FTILT
				shift_attack_angle()
				play_attack_animation("ftilt")
		_:
			character.currentAttack = null
	initialize_superarmour()
	disableInputDi = manage_disabled_inputDI()
	bufferedInput = null

func _physics_process(_delta):
	if !stateDone && !hitlagTimer.get_time_left():
		handle_input_disabled()
		if character.disableInput:
			process_movement_physics(_delta)
			if !check_in_air() && character.chargingSmashAttack:
				check_stop_area_entered(_delta)
				shift_attack_angle()
				if (Input.is_action_just_released(character.attack)\
				|| !Input.is_action_pressed(character.attack)):
					calculate_smash_multiplier()
					character.chargingSmashAttack = false
					character.smashAttack = null
					character.animatedSprite.set_rotation_degrees(rotateSmashAttackDegrees)
					character.apply_smash_attack_steps(2)
			if character.currentAttack == GlobalVariables.CharacterAnimations.DASHATTACK:
				check_stop_area_entered(_delta)
			if character.currentAttack == GlobalVariables.CharacterAnimations.JAB1\
			|| character.currentAttack == GlobalVariables.CharacterAnimations.JAB2\
			|| character.currentAttack == GlobalVariables.CharacterAnimations.JAB3:
				if character.comboNextJab:
					if Input.is_action_pressed(character.attack)\
					&& get_input_direction_x() == 0\
					&& get_input_direction_y() == 0:
						animationPlayer.stop()
						jab_handler()
						character.comboNextJab = false
		else:
			if character.smashAttack != null: 
				attack_handler_ground_smash_attacks()
			elif (abs(get_input_direction_x()) == 0 || character.jabCount > 0) \
			&& get_input_direction_y() == 0:
				jab_handler()
			elif get_input_direction_y() < 0:
				character.currentAttack = GlobalVariables.CharacterAnimations.UPTILT
				play_attack_animation("uptilt")
			elif get_input_direction_y() > 0:
				character.currentAttack = GlobalVariables.CharacterAnimations.DTILT
				play_attack_animation("dtilt")
			elif character.currentMaxSpeed == character.baseWalkMaxSpeed: 
				if character.currentMoveDirection == GlobalVariables.MoveDirection.LEFT:
					character.currentAttack = GlobalVariables.CharacterAnimations.FTILT
					shift_attack_angle()
					play_attack_animation("ftilt")
				elif character.currentMoveDirection == GlobalVariables.MoveDirection.RIGHT:
					character.currentAttack = GlobalVariables.CharacterAnimations.FTILT
					shift_attack_angle()
					play_attack_animation("ftilt")
			elif character.currentMaxSpeed == character.baseRunMaxSpeed: 
				#dash attack
				match character.currentMoveDirection:
					GlobalVariables.MoveDirection.LEFT:
						character.velocity.x = -character.dashAttackSpeed
					GlobalVariables.MoveDirection.RIGHT:
						character.velocity.x = character.dashAttackSpeed
				character.currentAttack = GlobalVariables.CharacterAnimations.DASHATTACK
				play_attack_animation("dash_attack")
			initialize_superarmour()
			manage_disabled_inputDI()
			
func attack_handler_ground_smash_attacks():
	create_smashAttackMultiplier_timer(smashAttackHoldFrames)
	if character.turnAroundSmashAttack:
		match character.currentMoveDirection:
			GlobalVariables.MoveDirection.RIGHT:
				character.velocity.x = 600
			GlobalVariables.MoveDirection.LEFT:
				character.velocity.x = -600
	else:
		character.velocity = Vector2.ZERO
	character.turnAroundSmashAttack = false
	var animationToPlay = null
	match character.smashAttack: 
		GlobalVariables.CharacterAnimations.UPSMASH:
			animationToPlay = "upsmash"
			character.currentAttack = GlobalVariables.CharacterAnimations.UPSMASH
		GlobalVariables.CharacterAnimations.DSMASH:
			animationToPlay = "dsmash"
			character.currentAttack = GlobalVariables.CharacterAnimations.DSMASH
		GlobalVariables.CharacterAnimations.FSMASHR:
			if character.currentMoveDirection != GlobalVariables.MoveDirection.RIGHT:
				character.currentMoveDirection = GlobalVariables.MoveDirection.RIGHT
				mirror_areas()
			animationToPlay = "fsmash"
			character.currentAttack = GlobalVariables.CharacterAnimations.FSMASH
		GlobalVariables.CharacterAnimations.FSMASHL:
			if character.currentMoveDirection != GlobalVariables.MoveDirection.LEFT:
				character.currentMoveDirection = GlobalVariables.MoveDirection.LEFT
				mirror_areas()
			animationToPlay = "fsmash"
			character.currentAttack = GlobalVariables.CharacterAnimations.FSMASH
	play_attack_animation(animationToPlay)
			
			
func jab_handler():
	character.comboNextJab = false
	match character.jabCount:
		0:
			character.currentAttack = GlobalVariables.CharacterAnimations.JAB1
			play_attack_animation("jab1")
		1:
			character.currentAttack = GlobalVariables.CharacterAnimations.JAB2
			play_attack_animation("jab2")
		2:
			character.currentAttack = GlobalVariables.CharacterAnimations.JAB3
			play_attack_animation("jab3")
	character.jabCount += 1
	if character.jabCount > character.jabCombo: 
		character.jabCount = 0
		
func handle_input():
	pass
	
func handle_input_disabled():
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
				character.change_state(GlobalVariables.CharacterState.CROUCH)
				return true
			elif collision.get_collider().is_in_group("Ground"):
				character.change_state(GlobalVariables.CharacterState.CROUCH)
				return true
	elif get_input_direction_y() >= 0.5 && !character.bufferedSmashAttack:
		character.change_state(GlobalVariables.CharacterState.CROUCH)
		return true
	return false

func switch_from_air_to_ground(landingLag):
	create_landingLag_timer(landingLag)
	match character.currentMoveDirection:
		GlobalVariables.MoveDirection.LEFT:
			if get_input_direction_x() > 0:
				character.currentMoveDirection = GlobalVariables.MoveDirection.RIGHT
				mirror_areas()
		GlobalVariables.MoveDirection.RIGHT:
			if get_input_direction_x() < 0:
				character.currentMoveDirection = GlobalVariables.MoveDirection.LEFT
				mirror_areas()
					
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

func create_smashAttackMultiplier_timer(waitTime):
	start_timer(smashAttackMultiplierTimer, waitTime)
	
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
	if character.currentAttack == GlobalVariables.CharacterAnimations.FSMASH\
	|| character.currentAttack == GlobalVariables.CharacterAnimations.FTILT:
		var direction = Vector2(get_input_direction_x(),get_input_direction_y())
		var angle = rad2deg(direction.angle())
		if angle <= -15.0: 
			angle = -15.0
		elif angle >= 15.0:
			angle = 15.0
		else: angle = 0.0
		rotateSmashAttackDegrees = angle
