extends State

class_name SpecialAir

var bReverseTimer = null
var bReverseFrames = 4.0

func _ready():
	character.currentHitBox = 1
	if character.groundAirMoveTransition: 
		if character.bufferInvincibilityFrames > 0:
			create_invincibility_timer(character.bufferInvincibilityFrames)
			character.bufferInvincibilityFrames = 0

func setup(change_state, transitionBufferedInput, animationPlayer, character):
	.setup(change_state, transitionBufferedInput, animationPlayer, character)
	bufferedInput = character.moveTransitionBufferedInput
	bReverseTimer = GlobalVariables.create_timer("on_b_reverse_timeout", "bReverseTimer", self)
	
func switch_to_current_state_again(transitionBufferedInput):
	self.transitionBufferedInput = transitionBufferedInput
	

func manage_transition_buffered_input():
	match transitionBufferedInput:
		GlobalVariables.CharacterAnimations.UPSPECIAL:
			if Input.is_action_pressed(character.jump):
				double_jump_attack_handler()
			play_attack_animation("upspecial")
			character.currentAttack = GlobalVariables.CharacterAnimations.UPSPECIAL
		GlobalVariables.CharacterAnimations.DOWNSPECIAL:
			if Input.is_action_pressed(character.jump):
				double_jump_attack_handler()
			play_attack_animation("downspecial")
			character.currentAttack = GlobalVariables.CharacterAnimations.DOWNSPECIAL
		GlobalVariables.CharacterAnimations.SIDESPECIAL:
			if Input.is_action_pressed(character.jump):
				double_jump_attack_handler()
			play_attack_animation("sidespecial")
			character.currentAttack = GlobalVariables.CharacterAnimations.SIDESPECIAL
		GlobalVariables.CharacterAnimations.NSPECIAL:
			if Input.is_action_pressed(character.jump):
				double_jump_attack_handler()
			play_attack_animation("neutralspecial")
			character.currentAttack = GlobalVariables.CharacterAnimations.NSPECIAL
	transitionBufferedInput = null
	character.initialize_special_animation_steps()
	character.disableInputDI = manage_disabled_inputDI()
	create_b_reverse_timer(bReverseFrames)

func manage_buffered_input():
	.manage_buffered_input_air()
	initialize_superarmour()
	character.disableInputDI = manage_disabled_inputDI()
	bufferedInput = null

func handle_input_disabled(_delta):
	if animationPlayer.is_playing():
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
			check_b_reverse()
		else:
			process_movement_physics_air(_delta)
		if character.airTime <= 300: 
			character.airTime += 1
		var solidGroundCollision = check_ground_platform_collision(character.platformCollisionDisabledTimer.get_time_left())
		if solidGroundCollision:
			character.onSolidGround = solidGroundCollision
			if character.moveAirGroundTransition.has(character.currentAttack):
#				character.check_special_animation_steps()
				character.bufferInvincibilityFrames = invincibilityTimer.get_time_left()
			else:
				if character.currentAttack && character.attackData.has(GlobalVariables.CharacterAnimations.keys()[character.currentAttack] + "_neutral"):
					var currentAttackData = character.attackData[GlobalVariables.CharacterAnimations.keys()[character.currentAttack] + "_neutral"]
					character.applyLandingLag = currentAttackData["landingLag"]
				else:
					character.applyLandingLag = character.normalLandingLag
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
				reset_gravity()
				play_attack_animation("upspecial")
				character.currentAttack = GlobalVariables.CharacterAnimations.UPSPECIAL
			elif get_input_direction_y() > 0:
				reset_gravity()
				play_attack_animation("downspecial")
				character.currentAttack = GlobalVariables.CharacterAnimations.DOWNSPECIAL
			elif get_input_direction_x() > 0 && character.currentMoveDirection == GlobalVariables.MoveDirection.LEFT\
			|| get_input_direction_x() < 0 && character.currentMoveDirection == GlobalVariables.MoveDirection.RIGHT: 
				if character.currentMoveDirection != GlobalVariables.MoveDirection.RIGHT:
					character.currentMoveDirection = GlobalVariables.MoveDirection.RIGHT
				elif character.currentMoveDirection != GlobalVariables.MoveDirection.LEFT:
					character.currentMoveDirection = GlobalVariables.MoveDirection.LEFT
				character.mirror_areas()
				play_attack_animation("sidespecial")
				character.currentAttack = GlobalVariables.CharacterAnimations.SIDESPECIAL
			elif character.currentMoveDirection == GlobalVariables.MoveDirection.LEFT:
				play_attack_animation("sidespecial")
				character.currentAttack = GlobalVariables.CharacterAnimations.SIDESPECIAL
			elif character.currentMoveDirection == GlobalVariables.MoveDirection.RIGHT:
				play_attack_animation("sidespecial")
				character.currentAttack = GlobalVariables.CharacterAnimations.SIDESPECIAL
			character.initialize_special_animation_steps()
			initialize_superarmour()
			character.disableInputDI = manage_disabled_inputDI()
			create_b_reverse_timer(bReverseFrames)

func manage_ground_air_move_transition():
	character.disableInput = true
	
func check_b_reverse():
	if bReverseTimer.get_time_left():
		match character.currentMoveDirection: 
			GlobalVariables.MoveDirection.LEFT: 
				if Input.is_action_pressed(character.right):
					character.currentMoveDirection = GlobalVariables.MoveDirection.RIGHT
					character.mirror_areas()
					bReverseTimer.stop()
			GlobalVariables.MoveDirection.RIGHT: 
				if Input.is_action_pressed(character.left):
					character.currentMoveDirection = GlobalVariables.MoveDirection.LEFT
					character.mirror_areas()
					bReverseTimer.stop()
					
func create_b_reverse_timer(waitTime):
	GlobalVariables.start_timer(bReverseTimer, waitTime)

func on_b_reverse_timeout():
	pass
