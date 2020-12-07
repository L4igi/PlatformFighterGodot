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
	var char2PushForce = char2.walkForce * char2.get_input_direction()
	var combinedVelocity = char1PushForce + char2PushForce
	#one character is standing still the other one moving
	char1.velocity.x = combinedVelocity
	char2.velocity.x = combinedVelocity

func add_ground_colliding_character(character):
	countGroundCollidingCharacters.append(character)
	calc_push_slowdown(character)
	
func calc_push_slowdown(character):
	character.walkMaxSpeed /= 2
#	character.walkForce = 200
	if character.velocity.x > character.walkMaxSpeed:
		character.velocity.x = character.walkMaxSpeed * character.get_input_direction()

func remove_ground_colliding_character(character):
	countGroundCollidingCharacters.erase(character)
	character.walkMaxSpeed = character.baseWalkMaxSpeed
	character.walkForce = character.baseWalkForce
