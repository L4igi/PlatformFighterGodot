extends Node

var allConnectedHitboxes = []

var allConnectedHurtBoxes = []

enum InteractionState {WIN, LOSE, REBOUND, TRANSCENDENT}

func add_connected_hitbox(attackingObject, hbType, attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, shieldStunMultiplier, shieldDamage, specialHitBoxEffects, hitlagMultiplier):
	allConnectedHitboxes.append([attackingObject,hbType, attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, shieldStunMultiplier, shieldDamage, specialHitBoxEffects, hitlagMultiplier])

func add_connected_hurtbox(attackingObject, attackedObject, hbType):
	allConnectedHurtBoxes.append([attackingObject, attackedObject, hbType])

func match_connected_hit_hurtboxes():
	while !allConnectedHurtBoxes.empty():
		for hitObject in allConnectedHitboxes: 
			for hurtObject in allConnectedHurtBoxes:
				if hurtObject[0] == hitObject[0]\
				&& hurtObject[2] == hitObject[1]:
					apply_attack_connected(hitObject, hurtObject[1])
					allConnectedHurtBoxes.erase(hurtObject)
					break
	allConnectedHitboxes.clear()
	allConnectedHurtBoxes.clear()

func _process(delta):
	if allConnectedHitboxes.size() >= 1\
	&& allConnectedHurtBoxes.size() >= 1:
		match_connected_hit_hurtboxes()

func apply_attack_connected(attackingObjectArray, attackedObject):
	var attackingObject = attackingObjectArray[0]
	var hitboxType = attackingObjectArray[1]
	var attackDamage = attackingObjectArray[2]
	var hitStun = attackingObjectArray[3]
	var launchAngle = attackingObjectArray[4]
	var launchVectorInversion = attackingObjectArray[5]
	var launchVelocity = attackingObjectArray[6]
	var weightLaunchVelocity = attackingObjectArray[7]
	var knockBackScaling = attackingObjectArray[8]
	var shieldStunMultiplier = attackingObjectArray[9]
	var shieldDamage = attackingObjectArray[10]
	var specialHitBoxEffects = attackingObjectArray[11]
	var hitlagMultiplier = attackingObjectArray[12]
	if attackedObject.is_in_group("Character"):
		if attackedObject.currentState == GlobalVariables.CharacterState.SHIELD\
		|| attackedObject.currentState == GlobalVariables.CharacterState.SHIELDSTUN:
			attackedObject.is_attacked_in_shield_calculations(attackDamage, shieldStunMultiplier, shieldDamage,  attackingObject.global_position)
		elif attackedObject.perfectShieldActivated:
			attackedObject.is_attacked_calculations_perfect_shield()
		else:
			manage_hurtbox_special_interactions_character(attackingObject, attackedObject, specialHitBoxEffects, attackDamage)
			attackedObject.is_attacked_calculations(attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling,  attackingObject.global_position)
	elif attackedObject.is_in_group("Projectile"):
		if !manage_hurtbox_special_interactions_projectile(attackingObject, attackedObject, specialHitBoxEffects, attackDamage):
			pass
	calculate_hitlag_frames_connected(attackingObject, attackedObject, attackDamage, hitlagMultiplier, launchVelocity, weightLaunchVelocity)
	
func calculate_hitlag_frames_connected(attackingObject, attackedObject, attackDamage, hitlagMultiplier, launchVelocity, weightLaunchVelocity):
	var attackingObjectHitlag = floor((attackDamage*0.65+4)*hitlagMultiplier + (attackingObject.state.hitlagTimer.get_time_left()*60))
	var attackedObjectHitlag = floor((attackDamage*0.65+4)*hitlagMultiplier + (attackedObject.state.hitlagTimer.get_time_left()*60))
	if attackedObject.is_in_group("Character"):
		if attackedObject.currentState == GlobalVariables.CharacterState.SHIELD\
		|| attackedObject.perfectShieldActivated:
			attackingObjectHitlag = floor(attackingObjectHitlag * 0.67)
			attackedObjectHitlag = floor(attackedObjectHitlag * 0.67)
#	attackingObjectHitlag = 200
#	attackedObjectHitlag = 200
	if attackedObject.multiObjectsConnected: 
		attackedObject.multiObjectsConnected = false
	else: 
		if attackingObject.is_in_group("Projectile")\
		&& attackedObject.is_in_group("Character"):
			attackingObject.projectileSpecialInteraction = GlobalVariables.ProjectileInteractions.HITOTHERCHARACTER
		GlobalVariables.start_timer(attackingObject.state.hitlagTimer, attackingObjectHitlag)
#	print("attackingObjectHitlag " +str(attackingObjectHitlag))
#	print("attackedObjectHitlag " +str(attackedObjectHitlag))
	if launchVelocity == 0 && weightLaunchVelocity == 0:
		attackedObject.is_attacked_handler_no_knockback(attackedObjectHitlag, attackingObject)
	else:
		attackedObject.is_attacked_handler(attackedObjectHitlag, attackingObject)
#	elif attackedObject.is_in_group("Projectile"):
#		attackedObject.state.create_hitlagAttacked_timer(attackedObjectHitlag)


func manage_hurtbox_special_interactions_projectile(attackingObject, attackedObject, specialHitBoxEffects, attackDamage):
	if attackedObject.is_in_group("Projectile"):
		var interactionTypeToUse = GlobalVariables.HitBoxInteractionType.CONNECTED
		var attackedObjectInteracted = attackedObject.apply_special_hitbox_effect_attacked(specialHitBoxEffects, attackingObject, attackDamage, interactionTypeToUse)
		if attackedObjectInteracted:
			return true
	return false
	
func manage_hurtbox_special_interactions_character(attackingObject, attackedObject, specialHitBoxEffects, attackDamage):
	if attackingObject.is_in_group("Character") && attackedObject.is_in_group("Character"):
		var interactionTypeToUse = GlobalVariables.HitBoxInteractionType.CONNECTED
		var attackedObjectInteracted = attackedObject.apply_special_hitbox_effect_attacked(specialHitBoxEffects, attackingObject, attackDamage, interactionTypeToUse)
