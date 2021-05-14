extends State

class_name HitStunGroundState
var hitStunGroundFrames = 25
#
func _ready():
	create_hitStun_timer(hitStunGroundFrames)

func setup(change_state, transitionBufferedInput, animationPlayer, character):
	.setup(change_state, transitionBufferedInput, animationPlayer, character)
	character.airTime = 0
	character.disabledEdgeGrab = false
	character.jumpCount = 0
#	character.velocity = Vector2.ZERO


func handle_input(_delta):
	if Input.is_action_just_pressed(character.attack):
		character.getUpType = Globals.CharacterAnimations.ATTACKGETUP
		character.change_state(Globals.CharacterState.GETUP)
	elif Input.is_action_just_pressed(character.up):
		character.getUpType = Globals.CharacterAnimations.NORMALGETUP
		character.change_state(Globals.CharacterState.GETUP)
	elif Input.is_action_just_pressed(character.left):
		character.getUpType = Globals.CharacterAnimations.ROLLGETUP
		if character.currentMoveDirection != Globals.MoveDirection.LEFT:
			character.currentMoveDirection = Globals.MoveDirection.LEFT
			character.mirror_areas()
		character.velocity.x = -400
		character.change_state(Globals.CharacterState.GETUP)
	elif Input.is_action_just_pressed(character.right):
		character.getUpType = Globals.CharacterAnimations.ROLLGETUP
		if character.currentMoveDirection != Globals.MoveDirection.RIGHT:
			character.currentMoveDirection = Globals.MoveDirection.RIGHT
			character.mirror_areas()
		character.velocity.x = 400
		character.change_state(Globals.CharacterState.GETUP)

func handle_input_disabled(_delta):
	pass

func _physics_process(_delta):
	if !stateDone:
		process_movement_physics(_delta)
		if !character.disableInput:
			handle_input(_delta)
			if character.pushingCharacter:
				if check_in_air():
					character.disableInput = false
					character.change_state(Globals.CharacterState.AIR)
