extends Node2D

onready var character = get_parent()
var raycastCollisionObject = null
var areaCollisionObject = null
var collisionAreaEntered = null
var stateAlreadyChanged = false
var _initial_position


func _ready():
	character.connect("character_state_changed", self, "_on_character_state_change")
	_initial_position = get_transform()
	
	
func _on_CollisionArea_area_entered(area):
	if area.is_in_group("CollisionArea"):
		#check if colliding object is a character
		areaCollisionObject = area.get_parent().get_parent()
		collisionAreaEntered = area
		match_character_states(character.currentState)
				
func match_character_states(characterState):
	match character.currentState:
		character.CharacterState.GROUND:
			match_standard_collision()
		character.CharacterState.AIR:
			match_no_collision()
		character.CharacterState.EDGE:
			match_no_collision()
		character.CharacterState.ATTACKGROUND:
			match_standard_collision()
		character.CharacterState.ATTACKAIR:
			match_no_collision()
		character.CharacterState.HITSTUNGROUND:
			match_standard_collision()
		character.CharacterState.HITSTUNAIR:
			match_no_collision()
		character.CharacterState.SPECIALGROUND:
			match_standard_collision()
		character.CharacterState.SPECIALAIR:
			match_no_collision()
		character.CharacterState.SHIELD:
			match_standard_collision()
		character.CharacterState.ROLL:
			match_no_collision()
		character.CharacterState.GRAB:
			match_standard_collision()
		character.CharacterState.INGRAB:
			match_no_collision()
		character.CharacterState.SPOTDODGE:
			match_no_collision()
		character.CharacterState.GETUP:
			match_no_collision()
		character.CharacterState.SHIELDBREAK:
			match_standard_collision()
		character.CharacterState.CROUCH: 
			match_standard_collision()
		character.CharacterState.EDGEGETUP:
			match_no_collision()
		character.CharacterState.SHIELDSTUN:
			match_no_collision()
		character.CharacterState.TECHAIR:
			match_no_collision()
		character.CharacterState.TECHGROUND:
			match_standard_collision()
			
func disable_collision():
	character.set_collision_mask_bit(0,false)
	CharacterInteractionHandler.remove_ground_colliding_character(character)

func enable_collision():
#	print(character.name + "  "+str(character.global_position.y) + "  "+str(character.velocity.y))
#	print(areaCollisionObject.name + "  "+str(areaCollisionObject.global_position.y) + "  "+str(areaCollisionObject.velocity.y))
	if character.global_position.y > areaCollisionObject.global_position.y && int(character.velocity.y) < 0:
		return
	elif areaCollisionObject.global_position.y > character.global_position.y && int(areaCollisionObject.velocity.y) < 0:
		return
	else:
		character.pushingCharacter = areaCollisionObject
		CharacterInteractionHandler.add_ground_colliding_character(character)
		character.set_collision_mask_bit(0,true)
	
func _on_CollisionArea_area_exited(area):
	if area.is_in_group("CollisionArea"):
		character.set_collision_mask_bit(0,false)
		#set everything to base
		CharacterInteractionHandler.remove_ground_colliding_character(character)
		collisionAreaEntered = null
		areaCollisionObject = null
		character.pushingCharacter = null

func _on_character_state_change(character, currentState):
	#print("state changed to " +str(character.name) + " " + str(character.currentState))
	if collisionAreaEntered != null: 
		if !stateAlreadyChanged:
			stateAlreadyChanged = true
			match_character_states(currentState)
			collisionAreaEntered.get_parent().get_parent().other_character_state_changed()
		stateAlreadyChanged = false
		
				
func reset_global_transform():
	set_transform(_initial_position)
	
func check_character_above():
	if areaCollisionObject.global_position.y >= character.global_position.y: 
		return true
	else: 
		return false

func match_standard_collision():
	match areaCollisionObject.currentState:
		character.CharacterState.GROUND:
			enable_collision()
		character.CharacterState.AIR:
			disable_collision()
		character.CharacterState.EDGE:
			disable_collision()
		character.CharacterState.ATTACKGROUND:
			enable_collision()
		character.CharacterState.ATTACKAIR:
			disable_collision()
		character.CharacterState.HITSTUNGROUND:
			enable_collision()
		character.CharacterState.HITSTUNAIR:
			disable_collision()
		character.CharacterState.SPECIALGROUND:
			enable_collision()
		character.CharacterState.SPECIALAIR:
			enable_collision()
		character.CharacterState.SHIELD:
			enable_collision()
		character.CharacterState.ROLL:
			disable_collision()
		character.CharacterState.GRAB:
			enable_collision()
		character.CharacterState.INGRAB:
			disable_collision()
		character.CharacterState.SPOTDODGE:
			disable_collision()
		character.CharacterState.GETUP:
			disable_collision()
		character.CharacterState.SHIELDBREAK:
			if character.onSolidGround:
				enable_collision()
			else: 
				disable_collision()
		character.CharacterState.EDGEGETUP:
			disable_collision()
		character.CharacterState.SHIELDSTUN:
			disable_collision()
		character.CharacterState.TECHAIR:
			disable_collision()
		character.CharacterState.TECHGROUND:
			enable_collision()

func match_no_collision():
	match areaCollisionObject.currentState:
		character.CharacterState.GROUND:
			disable_collision()
		character.CharacterState.AIR:
			disable_collision()
		character.CharacterState.EDGE:
			disable_collision()
		character.CharacterState.ATTACKGROUND:
			disable_collision()
		character.CharacterState.ATTACKAIR:
			disable_collision()
		character.CharacterState.HITSTUNGROUND:
			disable_collision()
		character.CharacterState.HITSTUNAIR:
			disable_collision()
		character.CharacterState.SPECIALGROUND:
			disable_collision()
		character.CharacterState.SPECIALAIR:
			disable_collision()
		character.CharacterState.SHIELD:
			disable_collision()
		character.CharacterState.ROLL:
			disable_collision()
		character.CharacterState.GRAB:
			disable_collision()
		character.CharacterState.INGRAB:
			disable_collision()
		character.CharacterState.SPOTDODGE:
			disable_collision()
		character.CharacterState.GETUP:
			disable_collision()
		character.CharacterState.SHIELDBREAK:
			disable_collision()
		character.CharacterState.CROUCH:
			disable_collision()
		character.CharacterState.EDGEGETUP:
			disable_collision()
		character.CharacterState.SHIELDSTUN:
			disable_collision()
		character.CharacterState.TECHAIR:
			disable_collision()
		character.CharacterState.TECHGROUND:
			disable_collision()
