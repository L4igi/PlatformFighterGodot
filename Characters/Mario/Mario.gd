extends Character

var upspecialInvincibilityFrames = 3.0


# Called when the node enters the scene tree for the first time.
func _ready():
	#air to ground transitions
	moveAirGroundTransition[GlobalVariables.CharacterAnimations.DAIR] = 1
	moveAirGroundTransition[GlobalVariables.CharacterAnimations.DOWNSPECIAL] = 1
	#ground to air transitions 
	moveGroundAirTransition[GlobalVariables.CharacterAnimations.DOWNSPECIAL] = 1
	set_base_stats()
	#set state factory according to character
	state_factory = MarioStateFactory.new()
	if !onSolidGround:
		change_state(GlobalVariables.CharacterState.AIR)
#	animationPlayer = $AnimatedSprite/AnimationPlayer
	
func set_base_stats():
	weight = 1.5
	baseWalkMaxSpeed = 300
	walkMaxSpeed = 300
	runMaxSpeed = 600
	baseRunMaxSpeed = 600
	jabCombo = 1
	upSpecialSpeed = Vector2(300, 1200)

func apply_attack_animation_steps(step = 0):
	match currentAttack:
		GlobalVariables.CharacterAnimations.DAIR: 
			manage_dair(step)
		GlobalVariables.CharacterAnimations.DASHATTACK:
			manage_dash_attack(step)
			
func apply_special_animation_steps(step = 0):
	match currentAttack:
		GlobalVariables.CharacterAnimations.UPSPECIAL:
			manage_up_special(step)
		GlobalVariables.CharacterAnimations.DOWNSPECIAL:
			manage_down_special(step)
		GlobalVariables.CharacterAnimations.SIDESPECIAL:
			pass
		GlobalVariables.CharacterAnimations.NSPECIAL:
			pass
	
func manage_dair(step):
	match step:
		0:
			velocity = Vector2.ZERO
			state.gravity_on_off("off")
			disableInputDI = false
		1:
			state.gravity_on_off("on")
			animationPlayer.stop(false)
			state.bufferedAnimation = true

func manage_dash_attack(step):
	match step: 
		0: 
			pushingAction = true
		1: 
			pushingAction = false

func manage_up_special(step = 0):
	upSpecialAnimationStep = step
	match step:
		0:
			enableSpecialInput = false
			state.create_invincibility_timer(upspecialInvincibilityFrames)
		1:
			#frame 6 start upwards momentum 
			enableSpecialInput = true
			match currentMoveDirection:
				GlobalVariables.MoveDirection.LEFT:
					velocity = Vector2(-upSpecialSpeed.x, -upSpecialSpeed.y)
				GlobalVariables.MoveDirection.RIGHT:
					velocity = Vector2(upSpecialSpeed.x, -upSpecialSpeed.y)
			
func manage_down_special(step = 0):
	downSpecialAnimationStep = step
	match step:
		0:
			enableSpecialInput = true
		1:
			disableInputDI = false
			enableSpecialInput = false
			edgeGrabShape.set_deferred("disabled", false)
			set_collision_mask_bit(1,true) 
		2:
			pass
		
	 
			
func change_to_special_state():
	if Input.is_action_just_pressed(up):
		change_state(GlobalVariables.CharacterState.SPECIALAIR)
	elif Input.is_action_just_pressed(down):
		change_state(GlobalVariables.CharacterState.SPECIALGROUND)
	elif Input.is_action_just_pressed(left):
		if onSolidGround:
			change_state(GlobalVariables.CharacterState.SPECIALGROUND)
		else:
			change_state(GlobalVariables.CharacterState.SPECIALAIR)
	elif Input.is_action_just_pressed(right):
		if onSolidGround:
			change_state(GlobalVariables.CharacterState.SPECIALGROUND)
		else:
			change_state(GlobalVariables.CharacterState.SPECIALAIR)
	else:
		if onSolidGround:
			change_state(GlobalVariables.CharacterState.SPECIALGROUND)
		else:
			change_state(GlobalVariables.CharacterState.SPECIALAIR)

func check_special_animation_steps():
	match currentAttack:
		GlobalVariables.CharacterAnimations.UPSPECIAL:
			match upSpecialAnimationStep:
				0:
					moveAirGroundTransition[GlobalVariables.CharacterAnimations.UPSPECIAL] = 1
					moveGroundAirTransition[GlobalVariables.CharacterAnimations.UPSPECIAL] = 1
				1:
					moveAirGroundTransition.erase(GlobalVariables.CharacterAnimations.UPSPECIAL)
					moveGroundAirTransition.erase(GlobalVariables.CharacterAnimations.UPSPECIAL)
		GlobalVariables.CharacterAnimations.NSPECIAL:
			pass
		GlobalVariables.CharacterAnimations.DOWNSPECIAL:
			match downSpecialAnimationStep:
				0:
					moveAirGroundTransition[GlobalVariables.CharacterAnimations.DOWNSPECIAL] = 1
					moveGroundAirTransition[GlobalVariables.CharacterAnimations.DOWNSPECIAL] = 1
				2:
					moveAirGroundTransition.erase(GlobalVariables.CharacterAnimations.DOWNSPECIAL)
					moveGroundAirTransition.erase(GlobalVariables.CharacterAnimations.DOWNSPECIAL)
		GlobalVariables.CharacterAnimations.SIDESPECIAL:
			pass

func initialize_special_animation_steps():
	match currentAttack:
		GlobalVariables.CharacterAnimations.UPSPECIAL:
			moveAirGroundTransition[GlobalVariables.CharacterAnimations.UPSPECIAL] = 1
			moveGroundAirTransition[GlobalVariables.CharacterAnimations.UPSPECIAL] = 1
		GlobalVariables.CharacterAnimations.NSPECIAL:
			pass
		GlobalVariables.CharacterAnimations.DOWNSPECIAL:
			moveAirGroundTransition[GlobalVariables.CharacterAnimations.DOWNSPECIAL] = 1
			moveGroundAirTransition[GlobalVariables.CharacterAnimations.DOWNSPECIAL] = 1
		GlobalVariables.CharacterAnimations.SIDESPECIAL:
			pass

func finish_special_animation(step):
	match currentAttack:
		GlobalVariables.CharacterAnimations.UPSPECIAL:
			moveAirGroundTransition.erase(GlobalVariables.CharacterAnimations.UPSPECIAL)
			moveGroundAirTransition.erase(GlobalVariables.CharacterAnimations.UPSPECIAL)
		GlobalVariables.CharacterAnimations.NSPECIAL:
			pass
		GlobalVariables.CharacterAnimations.DOWNSPECIAL:
			moveAirGroundTransition.erase(GlobalVariables.CharacterAnimations.DOWNSPECIAL)
			moveGroundAirTransition.erase(GlobalVariables.CharacterAnimations.DOWNSPECIAL)
		GlobalVariables.CharacterAnimations.SIDESPECIAL:
			pass
	.finish_special_animation(step)
