extends Node2D

onready var character = get_parent()
var raycastCollisionObject = null
var areaCollisionObject = null
var collisionAreaEntered = null

var _initial_position


func _ready():
	character.connect("character_state_changed", self, "_on_character_state_change")
	character.connect("character_turnaround", self, "_on_character_turnaround")
	_initial_position = get_transform()
	
func _on_CollisionArea_area_entered(area):
	if area.is_in_group("CollisionArea"):
		areaCollisionObject = area.get_parent().get_parent()
		collisionAreaEntered = area
		#manage air ground char interactions
		if character.currentState == character.CharacterState.AIR && areaCollisionObject.currentState == areaCollisionObject.CharacterState.AIR:
			character.set_collision_mask_bit(0,false)
		elif character.currentState == character.CharacterState.AIR && areaCollisionObject.currentState == areaCollisionObject.CharacterState.GROUND\
		|| character.currentState == character.CharacterState.AIR && areaCollisionObject.currentState == areaCollisionObject.CharacterState.HITSTUNGROUND:
			if character.global_position.y < areaCollisionObject.global_position.y && character.velocity.y > 0:
				character.set_collision_mask_bit(0,true)
				character.pushingCharacter = areaCollisionObject
#		#manage ground ground char interactions
		elif character.currentState == character.CharacterState.GROUND && areaCollisionObject.currentState == areaCollisionObject.CharacterState.GROUND:
			character.pushingCharacter = areaCollisionObject
			CharacterInteractionHandler.add_ground_colliding_character(character)
			character.set_collision_mask_bit(0,true)
		#manage characters on ground in hitstun/lying on ground
		elif character.currentState == character.CharacterState.HITSTUNGROUND && areaCollisionObject.currentState == areaCollisionObject.CharacterState.GROUND\
		|| character.currentState == character.CharacterState.GROUND && areaCollisionObject.currentState == areaCollisionObject.CharacterState.HITSTUNGROUND:
			character.pushingCharacter = areaCollisionObject
			CharacterInteractionHandler.add_ground_colliding_character(character)
			character.set_collision_mask_bit(0,true)
		elif character.currentState == character.CharacterState.AIR && areaCollisionObject.currentState == areaCollisionObject.CharacterState.HITSTUNGROUND\
		|| character.currentState == character.CharacterState.HITSTUNGROUND && areaCollisionObject.currentState == areaCollisionObject.CharacterState.HITSTUNGROUND:
			if character.global_position.y < areaCollisionObject.global_position.y && character.velocity.y > 0:
				character.set_collision_mask_bit(0,true)
				character.pushingCharacter = areaCollisionObject
		#manage attack push one character attacking one character grounded
		elif (character.currentState == character.CharacterState.ATTACKGROUND && areaCollisionObject.currentState == areaCollisionObject.CharacterState.GROUND)\
		|| (character.currentState == character.CharacterState.GROUND && areaCollisionObject.currentState == areaCollisionObject.CharacterState.ATTACKGROUND):
				character.pushingCharacter = areaCollisionObject
				CharacterInteractionHandler.add_ground_colliding_character(character)
				character.set_collision_mask_bit(0,true)
			
func _on_CollisionArea_area_exited(area):
	if area.is_in_group("CollisionArea"):
		character.set_collision_mask_bit(0,false)
		#set everything to base
		CharacterInteractionHandler.remove_ground_colliding_character(character)
		collisionAreaEntered = null
		character.pushingCharacter = null
#		if character.currentState == character.CharacterState.GROUND:
#			character.velocity.x = 0

func _on_character_state_change(currentState):
	#todo: check this out!!!
#	if currentState != character.CharacterState.GROUND || currentState != character.CharacterState.AIR:
#		return
	if collisionAreaEntered != null: 
		if currentState == character.CharacterState.GROUND || currentState == character.CharacterState.HITSTUNGROUND:
			character.set_collision_mask_bit(0,true)
			character.pushingCharacter = areaCollisionObject
			areaCollisionObject.pushingCharacter = character
			CharacterInteractionHandler.add_ground_colliding_character(character)
			CharacterInteractionHandler.add_ground_colliding_character(areaCollisionObject)
		elif currentState == character.CharacterState.AIR:
			character.set_collision_mask_bit(0,false)
			CharacterInteractionHandler.remove_ground_colliding_character(character)
		elif currentState == character.CharacterState.HITSTUNAIR:
			character.set_collision_mask_bit(0,false)
			CharacterInteractionHandler.remove_ground_colliding_character(character)
		elif currentState == character.CharacterState.GETUP:
			character.set_collision_mask_bit(0,false)
			CharacterInteractionHandler.remove_ground_colliding_character(character)
			
func _on_character_turnaround():
	if collisionAreaEntered != null:
		#remove when moving away
		if CharacterInteractionHandler.countGroundCollidingCharacters.has(character):
			if character.currentMoveDirection == character.moveDirection.RIGHT \
			&& character.global_position > areaCollisionObject.global_position :
				CharacterInteractionHandler.remove_ground_colliding_character(character)
			elif character.currentMoveDirection == character.moveDirection.LEFT \
			&& character.global_position < areaCollisionObject.global_position :
				CharacterInteractionHandler.remove_ground_colliding_character(character)
		#add when moving towards
		else: 
			if character.currentState == character.CharacterState.GROUND:
				CharacterInteractionHandler.add_ground_colliding_character(character)
				
				
func reset_global_transform():
	set_transform(_initial_position)
