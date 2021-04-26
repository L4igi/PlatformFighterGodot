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
	
func setup(change_state, transitionBufferedInput, animationPlayer, character):
	.setup(change_state, transitionBufferedInput, animationPlayer, character)
	character.airTime = 0
	character.airdodgeAvailable = true

func manage_buffered_input_air():
	if bufferedInput == GlobalVariables.CharacterAnimations.JUMP:
		character.change_state(GlobalVariables.CharacterState.AIR)
		bufferedInput = null
	else:
		.manage_buffered_input_air()

func manage_buffered_input():
	if tempGetUpType == GlobalVariables.CharacterAnimations.LEDGEJUMPGETUP:
		manage_buffered_input_air()
	else:
		manage_buffered_input_ground()

func manage_edge_getup_animation(getUpType, targetPosition, direction):
	character.snappedEdge = null
	character.getUpType = getUpType
	tempGetUpType = getUpType
	match getUpType: 
		GlobalVariables.CharacterAnimations.LEDGEROLLGETUP:
			character.velocity.x = direction*normalGetUpVelocity
			character.onEdge = false
			character.tween.interpolate_property(character, "global_position", character.global_position, targetPosition , float(character.rollGetupInvincibilityFrames)/60, Tween.TRANS_LINEAR, Tween.EASE_IN)
			play_animation("roll_getup")
		GlobalVariables.CharacterAnimations.LEDGENORMALGETUP:
			character.velocity.x = direction*rollGetUpVelocity
			character.onEdge = false
			character.tween.interpolate_property(character, "global_position", character.global_position, targetPosition , float(character.normalGetupInvincibilityFrames)/60, Tween.TRANS_LINEAR, Tween.EASE_IN)
			play_animation("normal_getup")
		GlobalVariables.CharacterAnimations.LEDGEATTACKGETUP:
			character.velocity.x = direction*attackgetUpVelocity
			character.onEdge = false
			character.tween.interpolate_property(character, "global_position", character.global_position, targetPosition , float(character.attackGetupInvincibilityFrames)/60, Tween.TRANS_LINEAR, Tween.EASE_IN)
			play_attack_animation("ledgeAttack_getup")
			character.currentAttack = GlobalVariables.CharacterAnimations.LEDGEATTACKGETUP
		GlobalVariables.CharacterAnimations.LEDGEJUMPGETUP:
			character.velocity.x = direction*attackgetUpVelocity
			character.onEdge = false
			character.tween.interpolate_property(character, "global_position", character.global_position, targetPosition , float(character.attackGetupInvincibilityFrames)/60, Tween.TRANS_LINEAR, Tween.EASE_IN)
			play_attack_animation("jump_getup")
	character.tween.start()
	
func handle_input(_delta):
	pass

func handle_input_disabled(_delta):
	if !bufferedInput:
		.buffer_input()

func _physics_process(_delta):
	if !stateDone:
		if character.disableInput:
			handle_input_disabled(_delta)
		else:
			handle_input(_delta)
		character.velocity = character.move_and_slide_with_snap(character.velocity, Vector2.DOWN, Vector2.UP, true)
	#	process_movement_physics(_delta)
