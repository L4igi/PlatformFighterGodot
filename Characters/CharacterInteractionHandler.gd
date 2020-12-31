extends Node

var countGroundCollidingCharacters = []
var initCalculations = false
var combinedVelocity = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if countGroundCollidingCharacters.size() == 2: 
		set_combined_velocity(delta)
		
func set_combined_velocity(delta):
	var char1 = countGroundCollidingCharacters[0]
	var char2 = countGroundCollidingCharacters[1]
	
	if !initCalculations: 
		initCalculations = true
		combinedVelocity = 0
		#special case for dash attacks
		#no slowdown 
		char1.currentPushSpeed = char1.currentMaxSpeed
		char2.currentPushSpeed = char2.currentMaxSpeed
		calc_push_slowdown(char1, char2)
		calc_push_slowdown(char2, char1)
		
	var char1XInput = char1.get_input_direction_x()
	var char1PushForce = char1.currentPushSpeed * char1XInput
	var char2XInput = char2.get_input_direction_x()
	var char2PushForce = char1.currentPushSpeed * char2XInput
	
	if char1.currentState == char1.CharacterState.HITSTUNGROUND \
	|| char1.inHitStun\
	|| char1.currentState == char1.CharacterState.SHIELD:
		char1PushForce = 0
	if char1.resetMovementSpeed && char1PushForce != 0: 
		char1.change_max_speed(char1XInput)
		char1.resetMovementSpeed = false
		initCalculations = false

	if char2.currentState == char2.CharacterState.HITSTUNGROUND \
	|| char2.inHitStun \
	|| char2.currentState == char2.CharacterState.SHIELD:
		char2PushForce = 0
	if char2.resetMovementSpeed && char2PushForce != 0:
		char2.change_max_speed(char2XInput)
		char2.resetMovementSpeed = false
		initCalculations = false
		
	if abs(char1.get_input_direction_x()) < 0.05 &&  abs(char2.get_input_direction_x()) < 0.05:
		char1PushForce = move_toward(char1PushForce, 0, char1.groundStopForce * delta)
		char2PushForce = move_toward(char2PushForce, 0, char2.groundStopForce * delta)
	else:
		char1PushForce = clamp(char1PushForce, -char1.currentPushSpeed, char1.currentPushSpeed)
		char2PushForce = clamp(char2PushForce, -char2.currentPushSpeed, char2.currentPushSpeed)
	combinedVelocity = (char1PushForce + char2PushForce)
	var maxWalkForce = max(char1.currentPushSpeed, char2.currentPushSpeed)
	if ignore_pulling_character(char2, char1) && disable_velcotiy_calc(char1):
		if char1.currentState != char1.CharacterState.ROLL:
			char1.velocity.x = clamp(combinedVelocity, -maxWalkForce, maxWalkForce)
	if ignore_pulling_character(char1, char2) && disable_velcotiy_calc(char2):
		if char2.currentState != char2.CharacterState.ROLL:
			char2.velocity.x = clamp(combinedVelocity, -maxWalkForce, maxWalkForce)
		
func ignore_pulling_character(char1, char2):
	if char1.currentMoveDirection == char1.moveDirection.LEFT \
	&& char1.global_position.x < char2.global_position.x \
	&& (char1.get_input_direction_x() != 0 && char2.get_input_direction_x() == 0):
		char2.velocity.x = 0
		return false
	elif char1.currentMoveDirection == char1.moveDirection.RIGHT \
	&& char1.global_position.x > char2.global_position.x \
	&& (char1.get_input_direction_x() != 0 && char2.get_input_direction_x() == 0):
		char2.velocity.x = 0
		return false
	return true
	
func disable_velcotiy_calc(character):
	if character.currentState == character.CharacterState.ROLL\
	|| character.currentState == character.CharacterState.GETUP:
		return true
	else: 
		return false
		
func add_ground_colliding_character(character):
	if !countGroundCollidingCharacters.has(character):
		countGroundCollidingCharacters.append(character)
	
func calc_push_slowdown(character1, character2):
	character1.currentPushSpeed = character1.currentMaxSpeed/(character2.weight) 
#	character.walkForce = 200
	if character1.velocity.x > character1.currentPushSpeed:
		character1.velocity.x = character1.currentPushSpeed * character1.get_input_direction_x()
		

func remove_ground_colliding_character(character):
	countGroundCollidingCharacters.erase(character)
	character.pushingCharacter = null
	initCalculations = false
	character.walkMaxSpeed = character.baseWalkMaxSpeed
	character.disableInputInfluence = character.baseDisableInputInfluence

