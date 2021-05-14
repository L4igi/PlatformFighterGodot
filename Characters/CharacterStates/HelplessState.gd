extends State

class_name HelplessState

func setup(change_state, transitionBufferedInput, animationPlayer, character):
	.setup(change_state, transitionBufferedInput, animationPlayer, character)
	character.jumpCount = 0
	play_animation("helpless")
	character.edgeGrabShape.set_deferred("disabled", false)

func manage_buffered_input():
	manage_buffered_input_air()
	
func handle_input(_delta):
	process_disable_input_direction_influence(_delta)
	if Input.is_action_just_pressed(character.down) && !character.onSolidGround && int(character.velocity.y) >= 0:
		character.gravity = character.fastFallGravity
		character.maxFallSpeed = character.maxFallSpeedFastFall
	if character.velocity.y > 0 && get_input_direction_y() >= 0.5: 
		character.set_collision_mask_bit(1,false)
	elif character.velocity.y > 0 && get_input_direction_y() < 0.5 && character.platformCollision == null && !character.platformCollisionDisabledTimer.get_time_left():
		character.set_collision_mask_bit(1,true) 

func handle_input_disabled(_delta):
	if !bufferedInput:
		.buffer_input()
	
func _physics_process(_delta):
	if !stateDone:
		handle_input(_delta)
		var solidGroundCollision = check_ground_platform_collision(character.platformCollisionDisabledTimer.get_time_left())
		if solidGroundCollision:
			character.onSolidGround = solidGroundCollision
			character.applyLandingLag = character.normalLandingLag
			character.change_state(Globals.CharacterState.GROUND)
		
