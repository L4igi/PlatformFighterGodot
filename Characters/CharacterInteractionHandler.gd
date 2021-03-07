extends Node

var countGroundCollidingCharacters = []
var initCalculations = false
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
		#special case for dash attacks
		#no slowdown 
		char1.currentPushSpeed = char1.currentMaxSpeed
		char2.currentPushSpeed = char2.currentMaxSpeed
		calc_push_slowdown(char1, char2)
		calc_push_slowdown(char2, char1)
		
	var char1XInput = calc_push_force(char1)
	var char2XInput = calc_push_force(char2)
	
	if disable_character_pushforce(char1):
		char1XInput = 0
	elif char1.resetMovementSpeed && char1XInput != 0: 
		char1.change_max_speed(char1XInput)
		char1.resetMovementSpeed = false
		char1.currentPushSpeed = char1.currentMaxSpeed
		calc_push_slowdown(char1, char2)
#
	if disable_character_pushforce(char2):
		char2XInput = 0
	elif char2.resetMovementSpeed && char2XInput != 0:
		char2.change_max_speed(char2XInput)
		char2.resetMovementSpeed = false
		char2.currentPushSpeed = char2.currentMaxSpeed
		calc_push_slowdown(char2, char1)
		
	#if no velocity is calculated call again with swapped parameters
	if !calc_characters_velocity(char1, char2, char1XInput, char2XInput):
		calc_characters_velocity(char2, char1, char2XInput, char1XInput)
		
#sets pushForce to 0 if character is in certain state
func disable_character_pushforce(character):
	if character.currentState == character.CharacterState.HITSTUNGROUND \
	|| character.inHitStun\
	|| character.currentState == character.CharacterState.SHIELD\
	|| character.currentState == character.CharacterState.GRAB\
	|| character.currentState == character.CharacterState.AIR\
	|| (character.inMovementLag && character.shortTurnAround):
#	|| (character.inMovementLag):
		return true
	return false

func calc_characters_velocity(char1, char2, char1XInput, char2XInput):
	var char1MoveDirection = moveDirectionCalculation(char1)
	var char2MoveDirection = moveDirectionCalculation(char2)
	if char1.global_position.x < char2.global_position.x:
		if char1XInput != 0 && char2XInput == 0:
			#character 1 is pushing char 2 is standing still
			if char1MoveDirection == char1.moveDirection.RIGHT:
				char1.velocity.x = char1XInput * char1.currentPushSpeed
				char2.velocity.x = char1.velocity.x
			#charcter 1 is running away from character 2 is standing still
			elif char1MoveDirection == char1.moveDirection.LEFT:
				char1.velocity.x = char1XInput * char1.currentMaxSpeed
				char2.velocity.x = 0
		elif char2XInput != 0 && char1XInput == 0:
			#character 2 is pushing char 1 is standing still
			if char2MoveDirection == char1.moveDirection.LEFT:
				char2.velocity.x = char2XInput * char2.currentPushSpeed
				char1.velocity.x = char2.velocity.x
			#charcter 2 is running away from character 1 is standing still
			elif char2MoveDirection == char1.moveDirection.RIGHT:
				char1.velocity.x = 0
				char2.velocity.x = char2XInput * char2.currentMaxSpeed
		#both characters are standing still
		elif char1XInput == 0 && char2XInput == 0: 
			char1.velocity.x = 0
			char2.velocity.x = 0
		#both characters posess push force in direction
		elif char1XInput != 0 && char2XInput != 0:
			if char1MoveDirection == char2MoveDirection\
			&& char1MoveDirection == char1.moveDirection.RIGHT:
				#character 1 is faster than character 2 therefore pushing both at character 1 speed 
				if abs(char1XInput) > abs(char2XInput):
					char1.velocity.x = char1XInput * char1.currentPushSpeed
					char2.velocity.x = char1.velocity.x
				else:
				#character 2 is faster than character 1 both run at their own speed
					char1.velocity.x = char1XInput * char1.currentMaxSpeed
					char2.velocity.x = char2XInput * char2.currentMaxSpeed
			elif char1MoveDirection == char2MoveDirection\
			&& char1MoveDirection == char1.moveDirection.LEFT:
				#character 2 is faster than character 1 therefore pushing both at character 1 speed 
				if abs(char2XInput) > abs(char1XInput):
					char2.velocity.x = char2XInput * char2.currentPushSpeed
					char1.velocity.x = char2.velocity.x
				else:
				#character 1 is faster than character 2 both run at their own speed
					char2.velocity.x = char2XInput * char2.currentMaxSpeed
					char1.velocity.x = char1XInput * char1.currentMaxSpeed
			elif char1MoveDirection != char2MoveDirection:
				#one is always negative the other one always positive therefore use addition
				var combinedPushForce = (char1XInput * char1.currentPushSpeed) + (char2XInput * char2.currentPushSpeed)
				char2.velocity.x = combinedPushForce
				char1.velocity.x = combinedPushForce
		#if velocity was calculated return true
		return true
	return false
		
func add_ground_colliding_character(character):
	if !countGroundCollidingCharacters.has(character):
		countGroundCollidingCharacters.append(character)
	
func calc_push_slowdown(character1, character2):
	character1.currentPushSpeed = character1.currentMaxSpeed/(character2.weight) 

func remove_ground_colliding_character(character):
	countGroundCollidingCharacters.erase(character)
	character.pushingCharacter = null
	initCalculations = false
	character.walkMaxSpeed = character.baseWalkMaxSpeed
	character.disableInputInfluence = character.baseDisableInputInfluence

func calc_push_force(character):
	if character.currentAttack == GlobalVariables.CharacterAnimations.DASHATTACK && character.pushingAttack: 
		match character.currentMoveDirection:
			character.moveDirection.LEFT:
				return -2.0
			character.moveDirection.RIGHT:
				return 2.0
	elif character.currentAttack == GlobalVariables.CharacterAnimations.DASHATTACK && !character.pushingAttack: 
		return 0.0
	elif character.turnAroundTimer.timer_running():
		match character.currentMoveDirection:
			character.moveDirection.LEFT:
				return 1.0
			character.moveDirection.RIGHT:
				return -1.0
	else:
		return character.get_input_direction_x()
		
func recalculate_init_calculation():
	initCalculations = false
	
func moveDirectionCalculation(character):
	if character.turnAroundTimer.timer_running():
		match character.currentMoveDirection: 
			character.moveDirection.LEFT:
				return character.moveDirection.RIGHT
			character.moveDirection.RIGHT:
				return character.moveDirection.LEFT
	return character.currentMoveDirection
				 

