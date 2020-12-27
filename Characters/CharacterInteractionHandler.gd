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
		calc_push_slowdown(char1, char2)
		calc_push_slowdown(char2, char1)

	var char1PushForce = char1.currentMaxSpeed * char1.get_input_direction_x()
	var char2PushForce = char2.currentMaxSpeed * char2.get_input_direction_x()
			
	if abs(char1.get_input_direction_x()) < 0.05 &&  abs(char2.get_input_direction_x()) < 0.05:
		char1PushForce = move_toward(char1PushForce, 0, char1.groundStopForce * delta)
		char2PushForce = move_toward(char2PushForce, 0, char2.groundStopForce * delta)
	else:
		char1PushForce = clamp(char1PushForce, -char1.currentMaxSpeed, char1.currentMaxSpeed)
		char2PushForce = clamp(char2PushForce, -char2.currentMaxSpeed, char2.currentMaxSpeed)
	combinedVelocity = (char1PushForce + char2PushForce)
	var maxWalkForce = max(char1.currentMaxSpeed, char2.currentMaxSpeed)
	if ignore_pulling_character(char2, char1):
		char1.velocity.x = clamp(combinedVelocity, -maxWalkForce, maxWalkForce)
	if ignore_pulling_character(char1, char2):
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
		
func add_ground_colliding_character(character):
	if !countGroundCollidingCharacters.has(character):
		countGroundCollidingCharacters.append(character)
	
func calc_push_slowdown(character1, character2):
	character1.currentMaxSpeed /= (character2.weight) 
#	character.walkForce = 200
	if character1.velocity.x > character1.currentMaxSpeed:
		character1.velocity.x = character1.currentMaxSpeed * character1.get_input_direction_x()

func remove_ground_colliding_character(character):
	countGroundCollidingCharacters.erase(character)
	character.pushingCharacter = null
	initCalculations = false
	character.walkMaxSpeed = character.baseWalkMaxSpeed
	character.disableInputInfluence = character.baseDisableInputInfluence

