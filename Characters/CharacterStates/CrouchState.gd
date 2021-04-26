extends State

class_name CrouchState
var dropDownTimer = null
var dropDownFrames = 2.0

func _ready():
	play_animation("crouch")
	dropDownTimer = create_timer("on_dropDown_timeout", "DropDownTimer")
	if character.onSolidGround && character.onSolidGround.is_in_group("Platform"):
		create_dropDown_timer(dropDownFrames)
	
func setup(change_state, transitionBufferedInput, animationPlayer, character):
	.setup(change_state, transitionBufferedInput, animationPlayer, character)
	character.velocity.x = 0
	character.airTime = 0
	character.disabledEdgeGrab = false
	character.jumpCount = 0
	character.airdodgeAvailable = true
	
func handle_input():
	if Input.is_action_just_pressed(character.attack):
		character.change_state(GlobalVariables.CharacterState.ATTACKGROUND)
	elif Input.is_action_just_pressed(character.special):
		character.change_state(GlobalVariables.CharacterState.SPECIALGROUND)
	elif Input.is_action_just_pressed(character.jump):
		bufferedInput = null
		create_shortHop_timer()
	elif dropDownTimer.get_time_left() && Input.is_action_just_pressed(character.shield):
		character.change_state(GlobalVariables.CharacterState.AIRDODGE)
	elif !dropDownTimer.get_time_left() && Input.is_action_just_pressed(character.shield):
		character.change_state(GlobalVariables.CharacterState.SHIELD)

func handle_input_disabled(_delta):
	if !shortHopTimer.get_time_left()\
	&& bufferedInput == null: 
		.buffer_input()
		
func manage_buffered_input():
	manage_buffered_input_ground()
	
func _physics_process(_delta):
	if !stateDone:
		if !character.disableInput:
			handle_input()
			if get_input_direction_y() <= 0.3:
				character.change_state(GlobalVariables.CharacterState.GROUND)
		else:
			handle_input_disabled(_delta)
	
func create_dropDown_timer(waitTime):
	start_timer(dropDownTimer, waitTime)

func on_dropDown_timeout():
	if get_input_direction_y() >= 0.8:
		character.create_platformCollisionDisabled_timer(character.platformCollisionDisableFrames)
		character.jumpCount = 1
		character.set_collision_mask_bit(1,false)
		character.change_state(GlobalVariables.CharacterState.AIR)
