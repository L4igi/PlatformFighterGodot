extends State

class_name CrouchState
var dropDownTimer = null
var dropDownFrames = 2.0/60.0
#platformcollisiontimer
var platformCollisionTimer = null
var platformCollisionFrames = 30.0/60.0

func _ready():
	play_animation("crouch")
	dropDownTimer = create_timer("on_dropDown_timeout", "DropDownTimer")
	if character.onSolidGround.is_in_group("Platform"):
		create_dropDown_timer(dropDownFrames)
	platformCollisionTimer = create_timer("on_platformCollisionTimer_timeout", "PlatformCollisionTimer")
	
func setup(change_state, animationPlayer, character, bufferedInput = null, bufferedAnimation= null):
	.setup(change_state, animationPlayer, character, bufferedInput, bufferedAnimation)
	character.velocity.x = 0
	character.airTime = 0
	character.disabledEdgeGrab = false
	character.jumpCount = 0
	
func handle_input():
	if Input.is_action_just_pressed(character.attack):
		bufferedInput = GlobalVariables.CharacterAnimations.DTILT
		character.change_state(GlobalVariables.CharacterState.ATTACKGROUND)
	elif Input.is_action_just_pressed(character.jump):
		bufferedInput = null
		create_shortHop_timer()

func handle_input_disabled():
	if !shortHopTimer.get_time_left():
		buffer_input()

	
func _physics_process(delta):
	if !stateDone:
		if !character.disableInput:
			handle_input()
			if get_input_direction_y() <= 0.3:
				character.change_state(GlobalVariables.CharacterState.GROUND)
		else:
			handle_input_disabled()
	
func create_dropDown_timer(waitTime):
	start_timer(dropDownTimer, waitTime)

func on_dropDown_timeout():
	if get_input_direction_y() >= 0.8:
		create_platformCollision_timer(platformCollisionFrames)
		character.jumpCount = 1
		character.set_collision_mask_bit(1,false)
		character.change_state(GlobalVariables.CharacterState.AIR)
		
func create_platformCollision_timer(waitTime):
	start_timer(platformCollisionTimer, waitTime)
