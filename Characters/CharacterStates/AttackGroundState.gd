extends State

class_name AttackGroundState
#landinglag
var landingLagTimer = null


func _ready():
	landingLagTimer = create_timer("on_landingLag_timeout", "LandingLagTimer")
	character.currentHitBox = 1
	if character.applyLandingLag:
		switch_from_air_to_ground(character.applyLandingLag)
		character.applyLandingLag = null

func setup(change_state, animationPlayer, character, bufferedInput = null, bufferedAnimation= null):
	.setup(change_state, animationPlayer, character, bufferedInput, bufferedAnimation)
	character.airTime = 0
	character.disabledEdgeGrab = false
	character.jumpCount = 0
	character.airdodgeAvailable = true

func manage_buffered_input():
	character.currentAttack = bufferedInput
	match bufferedInput:
		GlobalVariables.CharacterAnimations.JUMP:
			character.currentAttack = null
			bufferedInput = null
			process_jump()
		GlobalVariables.CharacterAnimations.JAB1:
			jab_handler()
		GlobalVariables.CharacterAnimations.JAB2:
			jab_handler()
		GlobalVariables.CharacterAnimations.JAB3:
			jab_handler()
		GlobalVariables.CharacterAnimations.GRAB:
			character.currentAttack = null
			bufferedInput = null
			character.change_state(GlobalVariables.CharacterState.GRAB)
		GlobalVariables.CharacterAnimations.DSMASH:
			character.smashAttack = bufferedInput
			attack_handler_ground_smash_attacks()
		GlobalVariables.CharacterAnimations.UPSMASH:
			character.smashAttack = bufferedInput
			attack_handler_ground_smash_attacks()
		GlobalVariables.CharacterAnimations.FSMASHL:
			character.smashAttack = bufferedInput
			attack_handler_ground_smash_attacks()
		GlobalVariables.CharacterAnimations.FSMASHR:
			character.smashAttack = bufferedInput
			attack_handler_ground_smash_attacks()
		GlobalVariables.CharacterAnimations.UPTILT:
			play_attack_animation("uptilt")
			character.currentAttack = GlobalVariables.CharacterAnimations.UPTILT
		GlobalVariables.CharacterAnimations.DTILT:
			play_attack_animation("dtilt")
			character.currentAttack = GlobalVariables.CharacterAnimations.DTILT
		GlobalVariables.CharacterAnimations.FTILTL:
			play_attack_animation("ftilt")
			if character.currentMoveDirection != GlobalVariables.MoveDirection.LEFT:
				character.currentMoveDirection = GlobalVariables.MoveDirection.LEFT
				mirror_areas()
			character.currentAttack = GlobalVariables.CharacterAnimations.FTILT
		GlobalVariables.CharacterAnimations.FTILTR:
			play_attack_animation("ftilt")
			if character.currentMoveDirection != GlobalVariables.MoveDirection.RIGHT:
				character.currentMoveDirection = GlobalVariables.MoveDirection.RIGHT
				mirror_areas()
			character.currentAttack = GlobalVariables.CharacterAnimations.FTILT
		_:
			character.currentAttack = null
	bufferedInput = null

func _physics_process(_delta):
	if !stateDone && !hitlagTimer.get_time_left():
		handle_input_disabled()
		if character.disableInput:
			process_movement_physics(_delta)
			if !check_in_air() && character.chargingSmashAttack:
				check_stop_area_entered(_delta)
				if (Input.is_action_just_released(character.attack)\
				|| !Input.is_action_pressed(character.attack)):
					character.chargingSmashAttack = false
					character.smashAttack = null
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
						match character.currentAttack:
							GlobalVariables.CharacterAnimations.JAB1:
#								if !hitlagTimer.get_time_left():
#									character.jabCount = 0
#									bufferedInput = GlobalVariables.CharacterAnimations.JAB1
#								else:
								bufferedInput = GlobalVariables.CharacterAnimations.JAB2
							GlobalVariables.CharacterAnimations.JAB2:
								bufferedInput = GlobalVariables.CharacterAnimations.JAB2
							GlobalVariables.CharacterAnimations.JAB3:
								bufferedInput = GlobalVariables.CharacterAnimations.JAB3
						character.comboNextJab = false
						manage_buffered_input()
		else:
			if character.smashAttack != null: 
				attack_handler_ground_smash_attacks()
			elif (abs(get_input_direction_x()) == 0 || character.jabCount > 0) \
			&& get_input_direction_y() == 0:
				jab_handler()
			elif get_input_direction_y() < 0:
				play_attack_animation("uptilt")
				character.currentAttack = GlobalVariables.CharacterAnimations.UPTILT
			elif get_input_direction_y() > 0:
				play_attack_animation("dtilt")
				character.currentAttack = GlobalVariables.CharacterAnimations.DTILT
			elif character.currentMaxSpeed == character.baseWalkMaxSpeed: 
				if character.currentMoveDirection == GlobalVariables.MoveDirection.LEFT:
					play_attack_animation("ftilt")
					character.currentAttack = GlobalVariables.CharacterAnimations.FTILT
				elif character.currentMoveDirection == GlobalVariables.MoveDirection.RIGHT:
					play_attack_animation("ftilt")
					character.currentAttack = GlobalVariables.CharacterAnimations.FTILT
			elif character.currentMaxSpeed == character.baseRunMaxSpeed: 
				#dash attack
				match character.currentMoveDirection:
					GlobalVariables.MoveDirection.LEFT:
						character.velocity.x = -character.dashAttackSpeed
					GlobalVariables.MoveDirection.RIGHT:
						character.velocity.x = character.dashAttackSpeed
				play_attack_animation("dash_attack")
				character.currentAttack = GlobalVariables.CharacterAnimations.DASHATTACK
			
func attack_handler_ground_smash_attacks():
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
	match character.jabCount:
		0:
			play_attack_animation("jab1")
			character.currentAttack = GlobalVariables.CharacterAnimations.JAB1
		1:
			play_attack_animation("jab2")
			character.currentAttack = GlobalVariables.CharacterAnimations.JAB2
		2:
			play_attack_animation("jab3")
			character.currentAttack = GlobalVariables.CharacterAnimations.JAB3
	character.jabCount += 1
	if character.jabCount > character.jabCombo: 
		character.jabCount = 0
		
func handle_input():
	pass
	
func handle_input_disabled():
	if !shortHopTimer.get_time_left():
		buffer_input()
		
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
