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
		calc_push_slowdown(char1, char2)
		calc_push_slowdown(char2, char1)
	
	var char1PushForce = char1.walkForce * char1.get_input_direction()
	var char2PushForce = char2.walkForce * char2.get_input_direction()
	if abs(char1PushForce) < char1.walkForce * 0.2 &&  abs(char2PushForce) < char2.walkForce * 0.2:
		char1PushForce = move_toward(char1PushForce, 0, char1.stopForce * delta)
		char2PushForce = move_toward(char2PushForce, 0, char2.stopForce * delta)
		combinedVelocity = (char1PushForce + char2PushForce)*delta
	else:
		char1PushForce = clamp(char1PushForce, -char1.walkMaxSpeed, char1.walkMaxSpeed)
		char2PushForce = clamp(char2PushForce, -char2.walkMaxSpeed, char2.walkMaxSpeed)
		combinedVelocity = (char1PushForce + char2PushForce)
	
#	if char1.get_input_direction() != 0 && char2.get_input_direction() != 0:
#		var maxWalkForce = max(char1.walkMaxSpeed, char2.walkMaxSpeed)
#		char1.velocity.x = clamp(combinedVelocity, -maxWalkForce, maxWalkForce)
#		char2.velocity.x = clamp(combinedVelocity, -maxWalkForce, maxWalkForce)
#	else:
	var maxWalkForce = max(char1.walkMaxSpeed, char2.walkMaxSpeed)
	if ignore_pulling_character(char2, char1):
		char1.velocity.x = clamp(combinedVelocity, -maxWalkForce, maxWalkForce)
	if ignore_pulling_character(char1, char2):
		char2.velocity.x = clamp(combinedVelocity, -maxWalkForce, maxWalkForce)

func ignore_pulling_character(char1, char2):
	if char1.currentMoveDirection == char1.moveDirection.LEFT \
	&& char1.global_position.x < char2.global_position.x \
	&& (char1.get_input_direction() != 0 && char2.get_input_direction() == 0):
		char2.velocity.x = 0
		return false
	elif char1.currentMoveDirection == char1.moveDirection.RIGHT \
	&& char1.global_position.x > char2.global_position.x \
	&& (char1.get_input_direction() != 0 && char2.get_input_direction() == 0):
		char2.velocity.x = 0
		return false
	return true
		
func add_ground_colliding_character(character):
	countGroundCollidingCharacters.append(character)
	
func calc_push_slowdown(character1, character2):
	character1.walkMaxSpeed /= (character2.weight) 
#	character.walkForce = 200
	if character1.velocity.x > character1.walkMaxSpeed:
		character1.velocity.x = character1.walkMaxSpeed * character1.get_input_direction()

func remove_ground_colliding_character(character):
	countGroundCollidingCharacters.erase(character)
	initCalculations = false
	character.walkMaxSpeed = character.baseWalkMaxSpeed
	character.walkForce = character.baseWalkForce
