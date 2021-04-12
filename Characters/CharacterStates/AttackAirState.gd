extends State

class_name AttackAirState
var platformCollisionDisabledTimer = null
var platformCollisionDisableFrames = 30.0/60.0

func _ready():
	platformCollisionDisabledTimer = create_timer("on_platformCollisionDisabled_timeout", "PlatformCollisionDisabledTimer")
	character.currentHitBox = 1
	if character.bufferPlatformCollisionDisabledFrames:
		create_platformCollisionDisabled_timer(character.bufferPlatformCollisionDisabledFrames)
		character.bufferPlatformCollisionDisabledFrames = 0

func setup(change_state, animationPlayer, character, bufferedInput = null, bufferedAnimation= null):
	.setup(change_state, animationPlayer, character, bufferedInput, bufferedAnimation)
	character.disabledEdgeGrab = true
	character.edgeGrabShape.set_deferred("disabled", true)

func manage_buffered_input():
	match bufferedInput:
		GlobalVariables.CharacterAnimations.JUMP:
			character.currentAttack = null
			bufferedInput = GlobalVariables.CharacterAnimations.JUMP
			character.change_state(GlobalVariables.CharacterState.AIR)
		GlobalVariables.CharacterAnimations.JAB1:
			play_attack_animation("nair")
			character.currentAttack = GlobalVariables.CharacterAnimations.NAIR
		GlobalVariables.CharacterAnimations.DSMASH:
			play_attack_animation("dair")
			character.currentAttack = GlobalVariables.CharacterAnimations.DAIR
		GlobalVariables.CharacterAnimations.UPSMASH:
			play_attack_animation("upair")
			character.currentAttack = GlobalVariables.CharacterAnimations.UPAIR
		GlobalVariables.CharacterAnimations.FSMASHL:
			if character.currentMoveDirection == GlobalVariables.MoveDirection.LEFT:
				play_attack_animation("fair")
				character.currentAttack = GlobalVariables.CharacterAnimations.FAIR
			elif character.currentMoveDirection == GlobalVariables.MoveDirection.RIGHT:
				play_attack_animation("bair")
				character.currentAttack = GlobalVariables.CharacterAnimations.BAIR
		GlobalVariables.CharacterAnimations.FSMASHR:
			if character.currentMoveDirection == GlobalVariables.MoveDirection.RIGHT:
				play_attack_animation("fair")
				character.currentAttack = GlobalVariables.CharacterAnimations.FAIR
			elif character.currentMoveDirection == GlobalVariables.MoveDirection.LEFT:
				play_attack_animation("bair")
				character.currentAttack = GlobalVariables.CharacterAnimations.BAIR
		GlobalVariables.CharacterAnimations.UPTILT:
			play_attack_animation("upair")
			character.currentAttack = GlobalVariables.CharacterAnimations.UPAIR
		GlobalVariables.CharacterAnimations.DTILT:
			play_attack_animation("dair")
			character.currentAttack = GlobalVariables.CharacterAnimations.DAIR
		GlobalVariables.CharacterAnimations.FTILTL:
			if character.currentMoveDirection == GlobalVariables.MoveDirection.LEFT:
				play_attack_animation("fair")
				character.currentAttack = GlobalVariables.CharacterAnimations.FAIR
			elif character.currentMoveDirection == GlobalVariables.MoveDirection.RIGHT:
				play_attack_animation("bair")
				character.currentAttack = GlobalVariables.CharacterAnimations.BAIR
		GlobalVariables.CharacterAnimations.FTILTR:
			if character.currentMoveDirection == GlobalVariables.MoveDirection.RIGHT:
				play_attack_animation("fair")
				character.currentAttack = GlobalVariables.CharacterAnimations.FAIR
			elif character.currentMoveDirection == GlobalVariables.MoveDirection.LEFT:
				play_attack_animation("bair")
				character.currentAttack = GlobalVariables.CharacterAnimations.BAIR
		_:
			character.currentAttack = null
	bufferedInput = null
	
func handle_input():
	pass

func handle_input_disabled():
	buffer_input()
	
	
func _physics_process(_delta):
	if !stateDone:
		handle_input_disabled()
		if disableInputDi:
			process_disable_input_direction_influence(_delta)
		else:
			process_movement_physics_air(_delta)
		if character.airTime <= 300: 
			character.airTime += 1
		var solidGroundCollision = check_ground_platform_collision(platformCollisionDisabledTimer.get_time_left())
		if solidGroundCollision:
			character.onSolidGround = solidGroundCollision
			var currentAttackData = character.attackData[GlobalVariables.CharacterAnimations.keys()[character.currentAttack] + "_neutral"]
			character.applyLandingLag = currentAttackData["landingLag"] / 60.0
			if character.currentAttack == GlobalVariables.CharacterAnimations.DAIR:
				character.change_state(GlobalVariables.CharacterState.ATTACKGROUND)
			else:
				character.change_state(GlobalVariables.CharacterState.GROUND)
			return
			#toggle_all_hitboxes("off")
		elif !character.disableInput:
			if abs(get_input_direction_x()) == 0\
			&& abs(get_input_direction_y()) == 0:
				disableInputDi = true
				play_attack_animation("nair")
				character.currentAttack = GlobalVariables.CharacterAnimations.NAIR
			elif get_input_direction_y() < 0:
				disableInputDi = true
				play_attack_animation("upair")
				character.currentAttack = GlobalVariables.CharacterAnimations.UPAIR
			elif get_input_direction_x() > 0 && character.currentMoveDirection == GlobalVariables.MoveDirection.RIGHT\
			|| get_input_direction_x() < 0 && character.currentMoveDirection == GlobalVariables.MoveDirection.LEFT: 
				disableInputDi = true
				play_attack_animation("fair")
				character.currentAttack = GlobalVariables.CharacterAnimations.FAIR
			elif get_input_direction_x() > 0 && character.currentMoveDirection == GlobalVariables.MoveDirection.LEFT\
			|| get_input_direction_x() < 0 && character.currentMoveDirection == GlobalVariables.MoveDirection.RIGHT: 
				disableInputDi = true
				play_attack_animation("bair")
				character.currentAttack = GlobalVariables.CharacterAnimations.BAIR
			elif get_input_direction_y() > 0:
				disableInputDi = true
				play_attack_animation("dair")
				character.currentAttack = GlobalVariables.CharacterAnimations.DAIR
		if character.velocity.y > 0 && get_input_direction_y() >= 0.5: 
			character.set_collision_mask_bit(1,false)
		elif character.velocity.y > 0 && get_input_direction_y() < 0.5 && character.platformCollision == null:
			character.set_collision_mask_bit(1,true)

func create_platformCollisionDisabled_timer(waitTime):
	start_timer(platformCollisionDisabledTimer, waitTime)
	
func on_platformCollisionDisabled_timeout():
	pass