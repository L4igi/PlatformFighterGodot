extends State

class_name EdgeGetUpState
var rollGetUpVelocity = 650
var normalGetUpVelocity = 0
var attackgetUpVelocity = 400
var jumpGetUpVelocity = 0
var tempGetUpType = null

func _ready():
	var direction = 1
	if character.currentMoveDirection == GlobalVariables.MoveDirection.LEFT: 
		direction = -1
	manage_edge_getup_animation(character.getUpType, character.characterTargetGetUpPosition, direction)
	character.getUpType = null
	character.canGetEdgeInvincibility = true
	
func setup(change_state, animationPlayer, character, bufferedInput = null, bufferedAnimation= null):
	.setup(change_state, animationPlayer, character, bufferedInput, bufferedAnimation)
	character.airTime = 0
	character.airdodgeAvailable = true

func manage_buffered_input_air():
	match bufferedInput: 
		GlobalVariables.CharacterAnimations.JAB1:
			character.change_state(GlobalVariables.CharacterState.ATTACKGROUND)
		GlobalVariables.CharacterAnimations.JUMP:
#			double_jump_handler()
			character.change_state(GlobalVariables.CharacterState.AIR)
#			character.disableInput = false
#		GlobalVariables.CharacterAnimations.GRAB:
#			character.change_state(GlobalVariables.CharacterState.GRAB)
		GlobalVariables.CharacterAnimations.FSMASHR:
			character.change_state(GlobalVariables.CharacterState.ATTACKAIR)
		GlobalVariables.CharacterAnimations.FSMASHL:
			character.change_state(GlobalVariables.CharacterState.ATTACKAIR)
		GlobalVariables.CharacterAnimations.UPSMASH:
			character.change_state(GlobalVariables.CharacterState.ATTACKAIR)
		GlobalVariables.CharacterAnimations.DSMASH: 
			character.change_state(GlobalVariables.CharacterState.ATTACKAIR)
		GlobalVariables.CharacterAnimations.UPTILT:
			character.change_state(GlobalVariables.CharacterState.ATTACKAIR)
		GlobalVariables.CharacterAnimations.DTILT:
			character.change_state(GlobalVariables.CharacterState.ATTACKAIR)
		GlobalVariables.CharacterAnimations.FTILTR:
			character.change_state(GlobalVariables.CharacterState.ATTACKAIR)
		GlobalVariables.CharacterAnimations.FTILTL:
			character.change_state(GlobalVariables.CharacterState.ATTACKAIR)
	bufferedInput = null

func manage_buffered_input():
	if tempGetUpType == GlobalVariables.CharacterAnimations.JUMPGETUP:
		manage_buffered_input_air()
	else:
		manage_buffered_input_ground()

func manage_edge_getup_animation(getUpType, targetPosition, direction):
	character.snappedEdge = null
	character.getUpType = getUpType
	tempGetUpType = getUpType
	match getUpType: 
		GlobalVariables.CharacterAnimations.ROLLGETUP:
			character.velocity.x = direction*normalGetUpVelocity
			character.onEdge = false
			character.tween.interpolate_property(character, "global_position", character.global_position, targetPosition , float(character.rollGetupInvincibilityFrames)/60, Tween.TRANS_LINEAR, Tween.EASE_IN)
			play_animation("roll_getup")
		GlobalVariables.CharacterAnimations.NORMALGETUP:
			character.velocity.x = direction*rollGetUpVelocity
			character.onEdge = false
			character.tween.interpolate_property(character, "global_position", character.global_position, targetPosition , float(character.normalGetupInvincibilityFrames)/60, Tween.TRANS_LINEAR, Tween.EASE_IN)
			play_animation("normal_getup")
		GlobalVariables.CharacterAnimations.ATTACKGETUP:
			character.velocity.x = direction*attackgetUpVelocity
			character.onEdge = false
			character.tween.interpolate_property(character, "global_position", character.global_position, targetPosition , float(character.attackGetupInvincibilityFrames)/60, Tween.TRANS_LINEAR, Tween.EASE_IN)
			play_attack_animation("attack_getup")
		GlobalVariables.CharacterAnimations.JUMPGETUP:
			character.velocity.x = direction*attackgetUpVelocity
			character.onEdge = false
			character.tween.interpolate_property(character, "global_position", character.global_position, targetPosition , float(character.attackGetupInvincibilityFrames)/60, Tween.TRANS_LINEAR, Tween.EASE_IN)
			play_attack_animation("jump_getup")
	
	character.tween.start()
	
func handle_input():
	pass

func handle_input_disabled():
	buffer_input()

func _physics_process(_delta):
	if !stateDone:
		if character.disableInput:
			handle_input_disabled()
		else:
			handle_input()
		character.velocity = character.move_and_slide_with_snap(character.velocity, Vector2.DOWN, Vector2.UP, true)
	#	process_movement_physics(_delta)
