extends Node2D

onready var character = get_parent()
var raycastCollisionObject = null
var areaCollisionObject = null
var collisionAreaEntered = null

func _ready():
	character.connect("character_state_changed", self, "_on_character_state_change")
	character.connect("character_turnaround", self, "_on_character_turnaround")

func _on_CollisionArea_area_entered(area):
	if area.is_in_group("CollisionArea"):
		areaCollisionObject = area.get_parent().get_parent()
		collisionAreaEntered = area
		#manage air ground char interactions
		if character.currentState == character.CharacterState.GROUND && areaCollisionObject.currentState == areaCollisionObject.CharacterState.AIR:
			character.set_collision_mask_bit(0,true)
		elif character.currentState == character.CharacterState.AIR && areaCollisionObject.currentState == areaCollisionObject.CharacterState.GROUND:
			character.set_collision_mask_bit(0,true)
		#manage ground ground char interactions
		elif character.currentState == character.CharacterState.GROUND && areaCollisionObject.currentState == areaCollisionObject.CharacterState.GROUND:
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

func _on_character_state_change(currentState):
	if collisionAreaEntered != null: 
		if currentState == character.CharacterState.GROUND:
			if character.currentState == character.CharacterState.GROUND && areaCollisionObject.currentState == areaCollisionObject.CharacterState.GROUND:
				character.pushingCharacter = areaCollisionObject
				CharacterInteractionHandler.add_ground_colliding_character(character)
				CharacterInteractionHandler.add_ground_colliding_character(areaCollisionObject)
				character.set_collision_mask_bit(0,true)
				areaCollisionObject.set_collision_mask_bit(0,true)
				_on_character_turnaround()
		if currentState == character.CharacterState.AIR:
			CharacterInteractionHandler.remove_ground_colliding_character(character)

func _on_character_turnaround():
	if collisionAreaEntered != null:
		print("turnaround " +str(character.currentMoveDirection)) 
		#remove when moving away
		if CharacterInteractionHandler.countGroundCollidingCharacters.has(character):
			if character.currentMoveDirection == character.moveDirection.RIGHT \
			&& character.global_position > areaCollisionObject.global_position :
				print("First")
				CharacterInteractionHandler.countGroundCollidingCharacters.erase(character)
			elif character.currentMoveDirection == character.moveDirection.LEFT \
			&& character.global_position < areaCollisionObject.global_position :
				print("second")
				CharacterInteractionHandler.countGroundCollidingCharacters.erase(character)
		#add when moving towards
		else: 
			CharacterInteractionHandler.countGroundCollidingCharacters.append(character)
