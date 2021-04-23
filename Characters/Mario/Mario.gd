extends Character

var specialCaseAttacks = [GlobalVariables.CharacterAnimations.DAIR]

# Called when the node enters the scene tree for the first time.
func _ready():
	#assign inputs to players
	
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
			pass
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

func manage_up_special(step):
	match step:
		0: 
			pass
		1:
			pass
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
