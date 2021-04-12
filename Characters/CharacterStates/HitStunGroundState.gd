extends State

class_name HitStunGroundState

func setup(change_state, animationPlayer, character, bufferedInput = null, bufferedAnimation= null):
	.setup(change_state, animationPlayer, character, bufferedInput, bufferedAnimation)
	character.airTime = 0
	character.disabledEdgeGrab = false
	character.jumpCount = 0


func handle_input():
	if Input.is_action_just_pressed(character.attack):
		character.getUpType = GlobalVariables.CharacterAnimations.ATTACKGETUP
		character.change_state(GlobalVariables.CharacterState.GETUP)
	elif Input.is_action_just_pressed(character.up):
		character.getUpType = GlobalVariables.CharacterAnimations.NORMALGETUP
		character.change_state(GlobalVariables.CharacterState.GETUP)
	elif Input.is_action_just_pressed(character.left):
		character.getUpType = GlobalVariables.CharacterAnimations.ROLLGETUP
		if character.currentMoveDirection != GlobalVariables.MoveDirection.LEFT:
			character.currentMoveDirection = GlobalVariables.MoveDirection.LEFT
			mirror_areas()
		character.velocity.x = -400
		character.change_state(GlobalVariables.CharacterState.GETUP)
	elif Input.is_action_just_pressed(character.right):
		character.getUpType = GlobalVariables.CharacterAnimations.ROLLGETUP
		if character.currentMoveDirection != GlobalVariables.MoveDirection.RIGHT:
			character.currentMoveDirection = GlobalVariables.MoveDirection.RIGHT
			mirror_areas()
		character.velocity.x = 400
		character.change_state(GlobalVariables.CharacterState.GETUP)

func handle_input_disabled():
	pass

func _physics_process(_delta):
	if !stateDone:
		if !character.disableInput:
			handle_input()
			check_in_air(_delta)
		process_movement_physics(_delta)