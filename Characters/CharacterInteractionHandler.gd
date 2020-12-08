extends Node

var countGroundCollidingCharacters = []
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if countGroundCollidingCharacters.size() == 2: 
		set_combined_velocity()
		
func set_combined_velocity():
	var char1 = countGroundCollidingCharacters[0]
	var char2 = countGroundCollidingCharacters[1]
	
	var char1PushForce = char1.walkForce * char1.get_input_direction()
	char1PushForce = clamp(char1PushForce, -char1.walkMaxSpeed, char1.walkMaxSpeed)
	var char2PushForce = char2.walkForce * char2.get_input_direction()
	char2PushForce = clamp(char2PushForce, -char2.walkMaxSpeed, char2.walkMaxSpeed)
	var combinedVelocity = char1PushForce + char2PushForce
#both characters face same direction enter area and front one moves 
#this should avoid pulling the other one 
#	print(char1.name +str(char1PushForce))
#	print(char2.name +str(char2PushForce))
	if char2.get_input_direction() == 0 \
	&& char1.currentMoveDirection == char1.moveDirection.LEFT \
	&& char1.global_position.x < char2.global_position.x:
		CharacterInteractionHandler.countGroundCollidingCharacters.erase(char1)
	if char2.get_input_direction() == 0 \
	&& char1.currentMoveDirection == char1.moveDirection.RIGHT \
	&& char1.global_position.x > char2.global_position.x:
		CharacterInteractionHandler.countGroundCollidingCharacters.erase(char1)
	#one character is standing still the other one moving
	var maxWalkForce = max(char1.walkMaxSpeed, char2.walkMaxSpeed)
	char1.velocity.x = clamp(combinedVelocity, -maxWalkForce, maxWalkForce)
	char2.velocity.x = clamp(combinedVelocity, -maxWalkForce, maxWalkForce)

func add_ground_colliding_character(character):
	countGroundCollidingCharacters.append(character)
	calc_push_slowdown(character)
	
func calc_push_slowdown(character):
	character.walkMaxSpeed /= (2*character.weight) 
#	character.walkForce = 200
	if character.velocity.x > character.walkMaxSpeed:
		character.velocity.x = character.walkMaxSpeed * character.get_input_direction()

func remove_ground_colliding_character(character):
	countGroundCollidingCharacters.erase(character)
	character.walkMaxSpeed = character.baseWalkMaxSpeed
	character.walkForce = character.baseWalkForce
