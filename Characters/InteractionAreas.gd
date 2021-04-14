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
		GlobalVariables.CharacterState.GROUND:
			match_standard_collision()
		GlobalVariables.CharacterState.AIR:
			match_no_collision()
		GlobalVariables.CharacterState.EDGE:
			match_no_collision()
		GlobalVariables.CharacterState.ATTACKGROUND:
			match_standard_collision()
		GlobalVariables.CharacterState.ATTACKAIR:
			match_no_collision()
		GlobalVariables.CharacterState.HITSTUNGROUND:
			match_standard_collision()
		GlobalVariables.CharacterState.HITSTUNAIR:
			match_no_collision()
		GlobalVariables.CharacterState.SPECIALGROUND:
			match_standard_collision()
		GlobalVariables.CharacterState.SPECIALAIR:
			match_no_collision()
		GlobalVariables.CharacterState.SHIELD:
			match_standard_collision()
		GlobalVariables.CharacterState.ROLL:
			match_no_collision()
		GlobalVariables.CharacterState.GRAB:
			match_standard_collision()
		GlobalVariables.CharacterState.INGRAB:
			match_no_collision()
		GlobalVariables.CharacterState.SPOTDODGE:
			match_no_collision()
		GlobalVariables.CharacterState.GETUP:
			match_no_collision()
		GlobalVariables.CharacterState.SHIELDBREAK:
			match_standard_collision()
		GlobalVariables.CharacterState.CROUCH: 
			match_standard_collision()
		GlobalVariables.CharacterState.EDGEGETUP:
			match_no_collision()
		GlobalVariables.CharacterState.SHIELDSTUN:
			match_no_collision()
		GlobalVariables.CharacterState.TECHAIR:
			match_no_collision()
		GlobalVariables.CharacterState.TECHGROUND:
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
	print("state changed to " +str(character.name) + " " + str(character.currentState))
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
		GlobalVariables.CharacterState.GROUND:
			enable_collision()
		GlobalVariables.CharacterState.AIR:
			disable_collision()
		GlobalVariables.CharacterState.EDGE:
			disable_collision()
		GlobalVariables.CharacterState.ATTACKGROUND:
			enable_collision()
		GlobalVariables.CharacterState.ATTACKAIR:
			disable_collision()
		GlobalVariables.CharacterState.HITSTUNGROUND:
			enable_collision()
		GlobalVariables.CharacterState.HITSTUNAIR:
			disable_collision()
		GlobalVariables.CharacterState.SPECIALGROUND:
			enable_collision()
		GlobalVariables.CharacterState.SPECIALAIR:
			enable_collision()
		GlobalVariables.CharacterState.SHIELD:
			enable_collision()
		GlobalVariables.CharacterState.ROLL:
			disable_collision()
		GlobalVariables.CharacterState.GRAB:
			enable_collision()
		GlobalVariables.CharacterState.INGRAB:
			disable_collision()
		GlobalVariables.CharacterState.SPOTDODGE:
			disable_collision()
		GlobalVariables.CharacterState.GETUP:
			disable_collision()
		GlobalVariables.CharacterState.SHIELDBREAK:
			if character.onSolidGround:
				enable_collision()
			else: 
				disable_collision()
		GlobalVariables.CharacterState.EDGEGETUP:
			disable_collision()
		GlobalVariables.CharacterState.SHIELDSTUN:
			disable_collision()
		GlobalVariables.CharacterState.TECHAIR:
			disable_collision()
		GlobalVariables.CharacterState.TECHGROUND:
			enable_collision()

func match_no_collision():
	match areaCollisionObject.currentState:
		GlobalVariables.CharacterState.GROUND:
			disable_collision()
		GlobalVariables.CharacterState.AIR:
			disable_collision()
		GlobalVariables.CharacterState.EDGE:
			disable_collision()
		GlobalVariables.CharacterState.ATTACKGROUND:
			disable_collision()
		GlobalVariables.CharacterState.ATTACKAIR:
			disable_collision()
		GlobalVariables.CharacterState.HITSTUNGROUND:
			disable_collision()
		GlobalVariables.CharacterState.HITSTUNAIR:
			disable_collision()
		GlobalVariables.CharacterState.SPECIALGROUND:
			disable_collision()
		GlobalVariables.CharacterState.SPECIALAIR:
			disable_collision()
		GlobalVariables.CharacterState.SHIELD:
			disable_collision()
		GlobalVariables.CharacterState.ROLL:
			disable_collision()
		GlobalVariables.CharacterState.GRAB:
			disable_collision()
		GlobalVariables.CharacterState.INGRAB:
			disable_collision()
		GlobalVariables.CharacterState.SPOTDODGE:
			disable_collision()
		GlobalVariables.CharacterState.GETUP:
			disable_collision()
		GlobalVariables.CharacterState.SHIELDBREAK:
			disable_collision()
		GlobalVariables.CharacterState.CROUCH:
			disable_collision()
		GlobalVariables.CharacterState.EDGEGETUP:
			disable_collision()
		GlobalVariables.CharacterState.SHIELDSTUN:
			disable_collision()
		GlobalVariables.CharacterState.TECHAIR:
			disable_collision()
		GlobalVariables.CharacterState.TECHGROUND:
			disable_collision()
