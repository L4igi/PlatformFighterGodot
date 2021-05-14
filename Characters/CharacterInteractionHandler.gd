extends Node

var countGroundCollidingCharacters = []
var initCalculations = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if countGroundCollidingCharacters.size() == 2: 
		set_combined_velocity(delta)
		
func set_combined_velocity(_delta):
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
		
	var calPushForceChar1Result = calc_push_force(char1)
	var calPushForceChar2Result = calc_push_force(char2)
	var char1XInput = calPushForceChar1Result[0]
	var char2XInput = calPushForceChar2Result[0]
	var char1Movedirection = calPushForceChar1Result[1]
	var char2Movedirection = calPushForceChar2Result[1]
	
	if disable_character_pushforce(char1):
		char1XInput = 0
	elif char1.resetMovementSpeed && char1XInput != 0 && !char1.pushingAction: 
		char1.change_max_speed(char1XInput)
		char1.resetMovementSpeed = false
		char1.currentPushSpeed = char1.currentMaxSpeed
		calc_push_slowdown(char1, char2)
#
	if disable_character_pushforce(char2):
		char2XInput = 0
	elif char2.resetMovementSpeed && char2XInput != 0 && !char2.pushingAction: 
		char2.change_max_speed(char2XInput)
		char2.resetMovementSpeed = false
		char2.currentPushSpeed = char2.currentMaxSpeed
		calc_push_slowdown(char2, char1)
		
	#if no velocity is calculated call again with swapped parameters
	if !calc_characters_velocity(char1, char2, char1XInput, char2XInput, char1Movedirection, char2Movedirection):
		calc_characters_velocity(char2, char1, char2XInput, char1XInput, char2Movedirection, char1Movedirection)
		
#sets pushForce to 0 if character is in certain state
func disable_character_pushforce(character):
	if character.currentState == Globals.CharacterState.HITSTUNGROUND\
	|| character.currentState == Globals.CharacterState.SHIELD\
	|| character.currentState == Globals.CharacterState.SHIELDSTUN\
	|| character.currentState == Globals.CharacterState.GRAB\
	|| character.currentState == Globals.CharacterState.AIR\
	|| (character.shortTurnAround)\
	|| (character.disableInput && !character.pushingAction):
#	|| character.hitStunTimer.timer_running()\
		return true
	return false

func calc_characters_velocity(char1, char2, char1XInput, char2XInput, char1MoveDirection, char2MoveDirection):
	if char1.global_position.x < char2.global_position.x:
		if char1XInput != 0 && char2XInput == 0:
			#character 1 is pushing char 2 is standing still
			if char1MoveDirection == Globals.MoveDirection.RIGHT:
				char1.velocity.x = char1XInput * char1.currentPushSpeed
				char2.velocity.x = char1.velocity.x
			#charcter 1 is running away from character 2 is standing still
			elif char1MoveDirection == Globals.MoveDirection.LEFT:
				char1.velocity.x = char1XInput * char1.currentMaxSpeed
				char2.velocity.x = 0
		elif char2XInput != 0 && char1XInput == 0:
			#character 2 is pushing char 1 is standing still
			if char2MoveDirection == Globals.MoveDirection.LEFT:
				char2.velocity.x = char2XInput * char2.currentPushSpeed
				char1.velocity.x = char2.velocity.x
			#charcter 2 is running away from character 1 is standing still
			elif char2MoveDirection == Globals.MoveDirection.RIGHT:
				char1.velocity.x = 0
				char2.velocity.x = char2XInput * char2.currentMaxSpeed
		#both characters are standing still
		elif char1XInput == 0 && char2XInput == 0: 
			char1.velocity.x = 0
			char2.velocity.x = 0
		#both characters posess push force in direction
		elif char1XInput != 0 && char2XInput != 0:
			if char1MoveDirection == char2MoveDirection\
			&& char1MoveDirection == Globals.MoveDirection.RIGHT:
				#character 1 is faster than character 2 therefore pushing both at character 1 speed 
				if abs(char1XInput) > abs(char2XInput):
					char1.velocity.x = char1XInput * char1.currentPushSpeed
					char2.velocity.x = char1.velocity.x
				else:
				#character 2 is faster than character 1 both run at their own speed
					char1.velocity.x = char1XInput * char1.currentMaxSpeed
					char2.velocity.x = char2XInput * char2.currentMaxSpeed
			elif char1MoveDirection == char2MoveDirection\
			&& char1MoveDirection == Globals.MoveDirection.LEFT:
				#character 2 is faster than character 1 therefore pushing both at character 1 speed 
				if abs(char2XInput) > abs(char1XInput):
					char2.velocity.x = char2XInput * char2.currentPushSpeed
					char1.velocity.x = char2.velocity.x
				else:
				#character 1 is faster than character 2 both run at their own speed
					char2.velocity.x = char2XInput * char2.currentMaxSpeed
					char1.velocity.x = char1XInput * char1.currentMaxSpeed
			elif char1MoveDirection != char2MoveDirection:
				if char1MoveDirection == Globals.MoveDirection.LEFT:
					char2.velocity.x = char2XInput * char2.currentPushSpeed
					char1.velocity.x = char1XInput * char1.currentPushSpeed
				else:
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
	if character.pushingAction: 
		match character.currentMoveDirection:
			Globals.MoveDirection.LEFT:
				return [-0.5,Globals.MoveDirection.LEFT]
			Globals.MoveDirection.RIGHT:
				return [0.5,Globals.MoveDirection.RIGHT]
#	elif character.currentAttack == Globals.CharacterAnimations.DASHATTACK && !character.pushingAction: 
#		return [0.0, character.currentMoveDirection]
	elif character.currentState == Globals.CharacterState.GROUND\
	&& character.state.turnAroundTimer.get_time_left():
		match character.currentMoveDirection:
			Globals.MoveDirection.LEFT:
				return [1.0, Globals.MoveDirection.RIGHT]
			Globals.MoveDirection.RIGHT:
				return [-1.0, Globals.MoveDirection.LEFT]
	else:
		return [character.state.get_input_direction_x(), character.currentMoveDirection]
		
func recalculate_init_calculation():
	initCalculations = false
	
#func moveDirectionCalculation(character):
#	if character.currentState == Globals.CharacterState.GROUND\
#	&& character.state.turnAroundTimer.get_time_left():
#		match character.currentMoveDirection: 
#			Globals.MoveDirection.LEFT:
#				return Globals.MoveDirection.RIGHT
#			Globals.MoveDirection.RIGHT:
#				return Globals.MoveDirection.LEFT
#	return character.currentMoveDirection
				 

