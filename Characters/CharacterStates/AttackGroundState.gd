extends State

class_name AttackGroundState
#landinglag
var inLandingLag = false
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

func manage_buffered_input():
	character.currentAttack = bufferedInput
	match bufferedInput:
		GlobalVariables.CharacterAnimations.JUMP:
			character.currentAttack = null
			bufferedInput = null
			process_jump()
		GlobalVariables.CharacterAnimations.JAB1:
			jab_handler()
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
			character.currentAttack = GlobalVariables.CharacterAnimations.FTILTL
		GlobalVariables.CharacterAnimations.FTILTR:
			play_attack_animation("ftilt")
			if character.currentMoveDirection != GlobalVariables.MoveDirection.RIGHT:
				character.currentMoveDirection = GlobalVariables.MoveDirection.RIGHT
				mirror_areas()
			character.currentAttack = GlobalVariables.CharacterAnimations.FTILTR
		_:
			character.currentAttack = null
	bufferedInput = null

func _physics_process(_delta):
	if !stateDone:
		handle_input_disabled()
		if character.disableInput:
			process_movement_physics(_delta)
			if !check_in_air(_delta) && character.chargingSmashAttack:
				if (Input.is_action_just_released(character.attack)\
				|| !Input.is_action_pressed(character.attack)):
					character.chargingSmashAttack = false
					character.smashAttack = null
					character.apply_smash_attack_steps(2)
			if character.currentAttack == GlobalVariables.CharacterAnimations.DASHATTACK:
				check_stop_area_entered()
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
					character.currentAttack = GlobalVariables.CharacterAnimations.FTILTL
				elif character.currentMoveDirection == GlobalVariables.MoveDirection.RIGHT:
					play_attack_animation("ftilt")
					character.currentAttack = GlobalVariables.CharacterAnimations.FTILTR
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
		GlobalVariables.CharacterAnimations.DSMASH:
			animationToPlay = "dsmash"
		GlobalVariables.CharacterAnimations.FSMASHR:
			if character.currentMoveDirection != GlobalVariables.MoveDirection.RIGHT:
				character.currentMoveDirection = GlobalVariables.MoveDirection.RIGHT
				mirror_areas()
			animationToPlay = "fsmash"
			character.currentAttack = character.smashAttack
		GlobalVariables.CharacterAnimations.FSMASHL:
			if character.currentMoveDirection != GlobalVariables.MoveDirection.LEFT:
				character.currentMoveDirection = GlobalVariables.MoveDirection.LEFT
				mirror_areas()
			animationToPlay = "fsmash"
	play_attack_animation(animationToPlay)
	character.currentAttack = character.smashAttack
			
			
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
	character.change_state(GlobalVariables.CharacterState.GROUND)
	
func check_stop_area_entered():
	if character.stopAreaEntered: 
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
