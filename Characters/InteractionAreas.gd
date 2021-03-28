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
			match_collision_ground()
		character.CharacterState.AIR:
			match_collision_air()
		character.CharacterState.EDGE:
			match_collision_edge()
		character.CharacterState.ATTACKGROUND:
			match_collision_attackground()
		character.CharacterState.ATTACKAIR:
			match_collision_attackair()
		character.CharacterState.HITSTUNGROUND:
			match_collision_hitstunground()
		character.CharacterState.HITSTUNAIR:
			match_collision_hitstunair()
		character.CharacterState.SPECIALGROUND:
			match_collision_specialground()
		character.CharacterState.SPECIALAIR:
			match_collision_specialair()
		character.CharacterState.SHIELD:
			match_collision_shield()
		character.CharacterState.ROLL:
			match_collision_roll()
		character.CharacterState.GRAB:
			match_collision_grab()
		character.CharacterState.INGRAB:
			match_collision_ingrab()
		character.CharacterState.SPOTDODGE:
			match_collision_spotdodge()
		character.CharacterState.GETUP:
			match_collision_getup()
		character.CharacterState.SHIELDBREAK:
			match_collision_shieldbreak()
		character.CharacterState.CROUCH: 
			match_collision_crouch()
		character.CharacterState.EDGEGETUP:
			match_collision_edgegetup()
		character.CharacterState.SHIELDSTUN:
			match_collision_shieldstun()
			
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


func match_collision_ground():
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
			
func match_collision_air():
	match areaCollisionObject.currentState:
		character.CharacterState.GROUND:
			disable_collision()
#			if check_character_above():
#				enable_collision()
#			else: 
#				disable_collision()
		character.CharacterState.AIR:
			disable_collision()
		character.CharacterState.EDGE:
			disable_collision()
		character.CharacterState.ATTACKGROUND:
			enable_collision()
		character.CharacterState.ATTACKAIR:
			disable_collision()
		character.CharacterState.HITSTUNGROUND:
			disable_collision()
#			if check_character_above():
#				enable_collision()
#			else: 
#				disable_collision()
		character.CharacterState.HITSTUNAIR:
			disable_collision()
		character.CharacterState.SPECIALGROUND:
			enable_collision()
		character.CharacterState.SPECIALAIR:
			disable_collision()
		character.CharacterState.SHIELD:
			disable_collision()
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
			disable_collision()
		character.CharacterState.CROUCH:
			disable_collision()
		character.CharacterState.EDGEGETUP:
			disable_collision()
		character.CharacterState.SHIELDSTUN:
			disable_collision()
			
func match_collision_edge():
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
			
func match_collision_attackground():
	match areaCollisionObject.currentState:
		character.CharacterState.GROUND:
			enable_collision()
		character.CharacterState.AIR:
			disable_collision()
		character.CharacterState.EDGE:
			disable_collision()
		character.CharacterState.ATTACKGROUND:
			disable_collision()
		character.CharacterState.ATTACKAIR:
			disable_collision()
		character.CharacterState.HITSTUNGROUND:
			enable_collision()
		character.CharacterState.HITSTUNAIR:
			disable_collision()
		character.CharacterState.SPECIALGROUND:
			enable_collision()
		character.CharacterState.SPECIALAIR:
			disable_collision()
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
		character.CharacterState.CROUCH:
			enable_collision()
		character.CharacterState.EDGEGETUP:
			disable_collision()
		character.CharacterState.SHIELDSTUN:
			disable_collision()

func match_collision_attackair():
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
			
func match_collision_hitstunground():
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
			disable_collision()
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
		character.CharacterState.CROUCH:
			enable_collision()
		character.CharacterState.EDGEGETUP:
			disable_collision()
		character.CharacterState.SHIELDSTUN:
			disable_collision()
			
func match_collision_hitstunair():
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
			
func match_collision_specialground():
	match areaCollisionObject.currentState:
		character.CharacterState.GROUND:
			enable_collision()
		character.CharacterState.AIR:
			enable_collision()
		character.CharacterState.EDGE:
			disable_collision()
		character.CharacterState.ATTACKGROUND:
			enable_collision()
		character.CharacterState.ATTACKAIR:
			enable_collision()
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
		character.CharacterState.CROUCH:
			enable_collision()
		character.CharacterState.EDGEGETUP:
			disable_collision()
		character.CharacterState.SHIELDSTUN:
			disable_collision()
			
func match_collision_specialair():
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
			disable_collision()
		character.CharacterState.SHIELD:
			disable_collision()
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
			disable_collision()
		character.CharacterState.CROUCH:
			enable_collision()
		character.CharacterState.EDGEGETUP:
			disable_collision()
		character.CharacterState.SHIELDSTUN:
			disable_collision()
			
func match_collision_shield():
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
			disable_collision()
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
		character.CharacterState.CROUCH:
			enable_collision()
		character.CharacterState.EDGEGETUP:
			disable_collision()
		character.CharacterState.SHIELDSTUN:
			disable_collision()
			
func match_collision_roll():
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
			
func match_collision_grab():
	match areaCollisionObject.currentState:
		character.CharacterState.GROUND:
			enable_collision()
		character.CharacterState.AIR:
			enable_collision()
		character.CharacterState.EDGE:
			disable_collision()
		character.CharacterState.ATTACKGROUND:
			enable_collision()
		character.CharacterState.ATTACKAIR:
			enable_collision()
		character.CharacterState.HITSTUNGROUND:
			disable_collision()
		character.CharacterState.HITSTUNAIR:
			disable_collision()
		character.CharacterState.SPECIALGROUND:
			enable_collision()
		character.CharacterState.SPECIALAIR:
			enable_collision()
		character.CharacterState.SHIELD:
			disable_collision()
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
		character.CharacterState.CROUCH:
			enable_collision()
		character.CharacterState.EDGEGETUP:
			disable_collision()
		character.CharacterState.SHIELDSTUN:
			disable_collision()
			
func match_collision_ingrab():
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
			
func match_collision_spotdodge():
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
			
func match_collision_getup():
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
			
func match_collision_shieldbreak():
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
			
func match_collision_crouch():
	match areaCollisionObject.currentState:
		character.CharacterState.GROUND:
			enable_collision()
		character.CharacterState.AIR:
			disable_collision()
#			if check_character_above():
#				enable_collision()
#			else: 
#				disable_collision()
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
		character.CharacterState.CROUCH:
			enable_collision()
		character.CharacterState.EDGEGETUP:
			disable_collision()
		character.CharacterState.SHIELDSTUN:
			disable_collision()
			
func match_collision_edgegetup():
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
			
func match_collision_shieldstun():
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
