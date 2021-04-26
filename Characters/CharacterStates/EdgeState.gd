extends State

class_name EdgeState
var edgeInvincibilityDuration = 0
#edgedrop timer
var edgeDropTimer = null
var edgeDropTimeLow = 120.0
var edgeDropTimeHigh = 150.0
var edgeRegrabFrames = 50.0

func _ready():
	edgeDropTimer = create_timer("on_edgeDrop_timeout", "EdgeDropTimer")
	var edgeDamagePercent = 120
	if character.damagePercent < edgeDamagePercent: 
		edgeDamagePercent = character.damagePercent
	edgeInvincibilityDuration = ((character.airTime*0.2+64)-(edgeDamagePercent*44/120))
	if character.damagePercent < 100: 
		create_edgeDrop_timer(edgeDropTimeLow)
	else: 
		create_edgeDrop_timer(edgeDropTimeHigh)
	if character.canGetEdgeInvincibility:
		character.canGetEdgeInvincibility = false
		create_invincibility_timer(edgeInvincibilityDuration)

func setup(change_state, transitionBufferedInput, animationPlayer, character):
	.setup(change_state, transitionBufferedInput, animationPlayer, character)
	character.airTime = 0

func _physics_process(delta):
	if !stateDone:
		if character.snappedEdge:
			handle_input()
			
func handle_input():
	if Input.is_action_just_pressed(character.down):
		disable_invincibility_edge_action()
		character.snappedEdge._on_EdgeSnap_area_exited(character.collisionAreaShape.get_parent())
		character.snappedEdge = null
		character.onEdge = false
#		character.velocity.x = -character.walkMaxSpeed/2
		character.disableInput = false
		character.change_state(GlobalVariables.CharacterState.AIR)
	elif Input.is_action_just_pressed(character.jump) || Input.is_action_just_pressed(character.up):
		character.getUpType = GlobalVariables.CharacterAnimations.LEDGEJUMPGETUP
		if character.global_position.x < character.snappedEdge.global_position.x:
			character.characterTargetGetUpPosition = character.snappedEdge.global_position - Vector2(-character.get_character_size().x/4, character.get_character_size().y)
		elif character.global_position.x > character.snappedEdge.global_position.x:
			character.characterTargetGetUpPosition = character.snappedEdge.global_position - Vector2(character.get_character_size().x/4, character.get_character_size().y)
		character.change_state(GlobalVariables.CharacterState.EDGEGETUP)
#		disable_invincibility_edge_action()
#		character.snappedEdge._on_EdgeSnap_area_exited(character.collisionAreaShape.get_parent())
#		character.snappedEdge = null
#		character.onEdge = false
#		shortHopTimer.stop()
#		bufferedInput = null
#		on_shorthop_timeout()
	elif Input.is_action_just_pressed(character.left):
		disable_invincibility_edge_action()
		if character.global_position.x < character.snappedEdge.global_position.x:
			character.snappedEdge._on_EdgeSnap_area_exited(character.collisionAreaShape.get_parent())
			character.snappedEdge = null
			character.onEdge = false
			character.velocity.x = -character.walkMaxSpeed/2
			character.disableInput = false
			character.change_state(GlobalVariables.CharacterState.AIR)
		else:
			character.getUpType = GlobalVariables.CharacterAnimations.LEDGENORMALGETUP
			character.characterTargetGetUpPosition = character.snappedEdge.global_position - Vector2(character.get_character_size().x/4, character.get_character_size().y)
			character.change_state(GlobalVariables.CharacterState.EDGEGETUP)
	elif Input.is_action_just_pressed(character.right):
		disable_invincibility_edge_action()
		if character.global_position.x > character.snappedEdge.global_position.x:
			character.snappedEdge._on_EdgeSnap_area_exited(character.collisionAreaShape.get_parent())
			character.snappedEdge = null
			character.onEdge = false
			character.velocity.x = character.walkMaxSpeed/2
			character.disableInput = false
			character.change_state(GlobalVariables.CharacterState.AIR)
		else: 
			character.getUpType = GlobalVariables.CharacterAnimations.LEDGENORMALGETUP
			character.characterTargetGetUpPosition = character.snappedEdge.global_position - Vector2(-character.get_character_size().x/4, character.get_character_size().y)
			character.change_state(GlobalVariables.CharacterState.EDGEGETUP)
	elif Input.is_action_just_pressed(character.shield):
		disable_invincibility_edge_action()
		if character.global_position > character.snappedEdge.global_position:
			character.getUpType = GlobalVariables.CharacterAnimations.LEDGEROLLGETUP
			character.characterTargetGetUpPosition = character.snappedEdge.global_position - Vector2((character.get_character_size()).x*2,(character.get_character_size()).y)
			character.change_state(GlobalVariables.CharacterState.EDGEGETUP)
		else: 
			character.getUpType = GlobalVariables.CharacterAnimations.LEDGEROLLGETUP
			character.characterTargetGetUpPosition = character.snappedEdge.global_position - Vector2(-(character.get_character_size()).x*2,(character.get_character_size()).y)
			character.change_state(GlobalVariables.CharacterState.EDGEGETUP)
	elif Input.is_action_just_pressed(character.attack):
		disable_invincibility_edge_action()
		if character.global_position > character.snappedEdge.global_position:
			character.getUpType = GlobalVariables.CharacterAnimations.LEDGEATTACKGETUP
			character.characterTargetGetUpPosition = character.snappedEdge.global_position - Vector2(character.get_character_size().x/4, character.get_character_size().y)
			character.change_state(GlobalVariables.CharacterState.EDGEGETUP)
		else:
			character.getUpType = GlobalVariables.CharacterAnimations.LEDGEATTACKGETUP
			character.characterTargetGetUpPosition = character.snappedEdge.global_position - Vector2(-character.get_character_size().x/4, character.get_character_size().y)
			character.change_state(GlobalVariables.CharacterState.EDGEGETUP)
	if !character.edgeRegrabTimer.get_time_left() && character.snappedEdge == null: 
		character.create_edgeRegrab_timer(edgeRegrabFrames)

func handle_input_disabled(_delta):
	pass

func disable_invincibility_edge_action():
	invincibilityTimer.stop()
	character.enable_disable_hurtboxes(true)

func create_edgeDrop_timer(waitTime):
	start_timer(edgeDropTimer, waitTime)

func on_edgeDrop_timeout():
	character.create_edgeRegrab_timer(edgeRegrabFrames)
	character.snappedEdge._on_EdgeSnap_area_exited(character.collisionAreaShape.get_parent())
	character.snappedEdge = null
	character.onEdge = false
	character.disableInput = false
	disable_invincibility_edge_action()
	match character.currentMoveDirection:
		GlobalVariables.MoveDirection.LEFT: 
			character.velocity.x = character.walkMaxSpeed/2
		GlobalVariables.MoveDirection.RIGHT:
			character.velocity.x = -character.walkMaxSpeed/2
	character.change_state(GlobalVariables.CharacterState.AIR)
