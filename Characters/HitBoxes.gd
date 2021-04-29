extends Node2D

onready var attackingObject = null
var attackingObjectState = null
onready var sweetSpot = $HitBoxSweetArea/Sweet
onready var neutralSpot = $HitBoxNeutralArea/Neutral
onready var sourSpot = $HitBoxSourArea/Sour
onready var specialSpot = $HitBoxSpecial/Special
var attackedObject = null
var attackedObjectArray = []

var hitBoxesConnected = []
var hitBoxesConnectedCopy = []

var hitBoxesClashed = []

enum HitBoxType {SOUR, NEUTRAL, SWEET, SPECIAL}

func _ready():
	attackingObject = get_parent().get_parent()

func _process(delta):
	if !hitBoxesClashed.empty():
		for interactionObject in attackedObjectArray:
			process_connected_hitboxes(hitBoxesClashed, GlobalVariables.HitBoxInteractionType.CLASHED, interactionObject)
		hitBoxesClashed.clear()
		hitBoxesConnected.clear()
	else:
		if !hitBoxesConnected.empty():
			for interactionObject in attackedObjectArray:
				if interactionObject.is_in_group("Character"):
					if attackingObject.currentState != GlobalVariables.CharacterState.GRAB:
						process_connected_hitboxes(hitBoxesConnected, GlobalVariables.HitBoxInteractionType.CONNECTED, interactionObject)
				elif interactionObject.is_in_group("Projectile"):
					process_connected_hitboxes(hitBoxesConnected, GlobalVariables.HitBoxInteractionType.CONNECTED, interactionObject)
			hitBoxesConnected.clear()
		
func process_connected_hitboxes(hitBoxes, interactionType, interactionObject):
	attackingObject.toggle_all_hitboxes("off")
	var highestHitBox = get_hightest_priority_hitbox(attackingObject, hitBoxes)
	if interactionObject == attackedObjectArray[attackedObjectArray.size()-1]:
		hitBoxes.clear()
	hitBoxesConnectedCopy = hitBoxesConnected.duplicate(true)
	match interactionType:
		GlobalVariables.HitBoxInteractionType.CONNECTED:
			apply_attack(highestHitBox, GlobalVariables.HitBoxInteractionType.CONNECTED, interactionObject)
		GlobalVariables.HitBoxInteractionType.CLASHED:
			apply_attack(highestHitBox, GlobalVariables.HitBoxInteractionType.CLASHED, interactionObject)
	return highestHitBox
	
func get_hightest_priority_hitbox(object, hitboxes):
	var highestHitboxPriority = 0
	var highestHitBox = null
	for hitbox in hitboxes: 
		match hitbox:
			HitBoxType.SOUR:
				if object.attackData[object.attackDataEnum.keys()[object.currentAttack] + "_sour"]["priority"] >= highestHitboxPriority:
					highestHitboxPriority = object.attackData[object.attackDataEnum.keys()[object.currentAttack] + "_sour"]["priority"]
					highestHitBox = HitBoxType.SOUR
			HitBoxType.NEUTRAL:
				if object.attackData[object.attackDataEnum.keys()[object.currentAttack] + "_neutral"]["priority"] >= highestHitboxPriority:
					highestHitboxPriority = object.attackData[object.attackDataEnum.keys()[object.currentAttack] + "_neutral"]["priority"]
					highestHitBox = HitBoxType.NEUTRAL
			HitBoxType.SWEET:
				if object.attackData[object.attackDataEnum.keys()[object.currentAttack] + "_sweet"]["priority"] >= highestHitboxPriority:
					highestHitboxPriority = object.attackData[object.attackDataEnum.keys()[object.currentAttack] + "_sweet"]["priority"]
					highestHitBox = HitBoxType.SWEET
			HitBoxType.SPECIAL:
				if object.attackData[object.attackDataEnum.keys()[object.currentAttack] + "_special"]["priority"] >= highestHitboxPriority:
					highestHitboxPriority = object.attackData[object.attackDataEnum.keys()[object.currentAttack] + "_special"]["priority"]
					highestHitBox = HitBoxType.SPECIAL
	return highestHitBox
	
func get_attackData_match_highest_hitbox_json_data(object, hbType):
	var combinedAttackDataString = object.currentAttack
	print(str(object.attackDataEnum.keys()[combinedAttackDataString]) + " " + str(hbType))
	match hbType:
		HitBoxType.SOUR:
			combinedAttackDataString = object.attackDataEnum.keys()[combinedAttackDataString] + "_sour"
		HitBoxType.NEUTRAL:
			combinedAttackDataString = object.attackDataEnum.keys()[combinedAttackDataString] + "_neutral"
		HitBoxType.SWEET:
			combinedAttackDataString = object.attackDataEnum.keys()[combinedAttackDataString] + "_sweet"
		HitBoxType.SPECIAL:
			combinedAttackDataString = object.attackDataEnum.keys()[combinedAttackDataString] + "_special"
	print("combinedAttackDataString " +str(combinedAttackDataString))
	return object.attackData[combinedAttackDataString]
		
func apply_attack(hbType, interactionType, interactionObject):
	var currentHitBoxNumber = attackingObject.currentHitBox
	var currentAttackData = get_attackData_match_highest_hitbox_json_data(attackingObject, hbType)
	var attackDamage = currentAttackData["damage_" + String(currentHitBoxNumber)]
	#calculate damage if charged smash attack
	if attackingObject.is_in_group("Character"):
		if attackingObject.currentAttack == GlobalVariables.CharacterAnimations.COUNTER:
			attackDamage = clamp(attackingObject.bufferedCounterDamage, attackDamage, 100)
		attackDamage *= attackingObject.smashAttackMultiplier
	attackDamage = stepify(attackDamage, 0.1)
	var hitStun = currentAttackData["hitStun_" + String(currentHitBoxNumber)]
	var launchAngle = deg2rad(currentAttackData["launchAngle_" + String(currentHitBoxNumber)])
	var launchVector = Vector2(cos(launchAngle), sin(launchAngle))
	var knockBackScaling = currentAttackData["knockBackGrowth_" + String(currentHitBoxNumber)]/100
	var launchVectorInversion = false
	var reboundingHitbox = currentAttackData["rebounding_" + String(currentHitBoxNumber)]
	var transcendentHitBox = currentAttackData["transcendent_" + String(currentHitBoxNumber)]
	##direction player if facing
	if currentAttackData["facing_direction"] == 0:
		match attackingObject.currentMoveDirection:
			GlobalVariables.MoveDirection.RIGHT:
				launchVectorInversion = false
			GlobalVariables.MoveDirection.LEFT:
				launchVectorInversion = true
	elif currentAttackData["facing_direction"] == 1\
	&& attackedObject.global_position.x < attackingObject.global_position.x:
		match attackingObject.currentMoveDirection:
			GlobalVariables.MoveDirection.RIGHT:
				launchVectorInversion = false
			GlobalVariables.MoveDirection.LEFT:
				launchVectorInversion = true
	#opposit direction player if facing
	if currentAttackData["facing_direction"] == 2:
		match attackingObject.currentMoveDirection:
			GlobalVariables.MoveDirection.RIGHT:
				launchVectorInversion = true
			GlobalVariables.MoveDirection.LEFT:
				launchVectorInversion = false
	#always send attacked attackingObject in the direction it is in comparison to attacker
	elif currentAttackData["facing_direction"] == 3:
		if attackedObject.global_position.x <= attackingObject.global_position.x:
			launchVectorInversion = true
		else:
			launchVectorInversion = false
	var launchVelocity = currentAttackData["launchVelocity_" + String(currentHitBoxNumber)]
	var weightLaunchVelocity = currentAttackData["launchVelocityWeight_" + String(currentHitBoxNumber)]
	var shieldStunMultiplier = currentAttackData["shieldStun_multiplier_" + String(currentHitBoxNumber)]
	var shieldDamage = currentAttackData["shield_damage_" + String(currentHitBoxNumber)]
	#todo check if is projectile
	var isProjectile = false
	var hitlagMultiplier = currentAttackData["hitlag_multiplier_" + String(currentHitBoxNumber)]
	var specialHitBoxEffects = []
	for effect in currentAttackData.get("effects_" +String(currentHitBoxNumber)).values():
		specialHitBoxEffects.append(GlobalVariables.SpecialHitboxType.keys().find(effect))
	match interactionType:
		GlobalVariables.HitBoxInteractionType.CONNECTED:
			apply_attack_connected(interactionObject, attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, shieldDamage, shieldStunMultiplier, hitlagMultiplier, specialHitBoxEffects)
		GlobalVariables.HitBoxInteractionType.CLASHED:
			apply_attack_clashed(interactionObject, attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, shieldDamage, shieldStunMultiplier, hitlagMultiplier, reboundingHitbox, transcendentHitBox, specialHitBoxEffects)

func apply_attack_connected(interactionObject, attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, shieldDamage, shieldStunMultiplier, hitlagMultiplier, specialHitBoxEffects):
	if interactionObject.is_in_group("Character"):
		if interactionObject.currentState == GlobalVariables.CharacterState.SHIELD:
			interactionObject.is_attacked_in_shield_calculations(attackDamage, shieldStunMultiplier, shieldDamage, isProjectile, attackingObject.global_position)
		elif interactionObject.perfectShieldActivated:
			interactionObject.is_attacked_calculations_perfect_shield()
		else:
			interactionObject.is_attacked_calculations(attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, attackingObject.global_position)
	elif interactionObject.is_in_group("Projectile"):
		if !manage_hurtbox_special_interactions_projectile(attackingObject, interactionObject, specialHitBoxEffects, attackDamage):
#			attackedObject.is_attacked_calculations(attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, attackingObject.global_position)
			pass
	calculate_hitlag_frames_connected(interactionObject, attackDamage, hitlagMultiplier, launchVelocity, weightLaunchVelocity)

func apply_attack_clashed(interactionObject, attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, shieldDamage, shieldStunMultiplier, hitlagMultiplier, reboundingHitbox, transcendentHitBox, specialHitBoxEffects):
	if interactionObject.is_in_group("Character")\
	&& attackingObject.is_in_group("Character"):
		apply_attack_clashed_character_character(interactionObject, attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, shieldDamage, shieldStunMultiplier, hitlagMultiplier, reboundingHitbox, transcendentHitBox, specialHitBoxEffects)
	elif (attackingObject.is_in_group("Projectile")\
	&& interactionObject.is_in_group("Character"))\
	|| (attackingObject.is_in_group("Character")\
	&& interactionObject.is_in_group("Projectile")): 
		apply_attack_clashed_character_projectile(interactionObject, attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, shieldDamage, shieldStunMultiplier, hitlagMultiplier, reboundingHitbox, transcendentHitBox, specialHitBoxEffects)
	#projectile projectile interaction 
	elif interactionObject.is_in_group("Projectile")\
	&& attackingObject.is_in_group("Projectile"):
		apply_attack_clashed_projectile_projectile(interactionObject, attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, shieldDamage, shieldStunMultiplier, hitlagMultiplier, reboundingHitbox, transcendentHitBox, specialHitBoxEffects) 
			
			
func apply_attack_clashed_character_character(interactionObject, attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, shieldDamage, shieldStunMultiplier, hitlagMultiplier, reboundingHitbox, transcendentHitBox, specialHitBoxEffects):
		var attackingObjectAttackType = GlobalVariables.match_attack_type_character(attackingObject.currentAttack)
		var attackedObjectAttackType = GlobalVariables.match_attack_type_character(interactionObject.currentAttack)
		#match interaction cases
		#check case if attack has Transcendent priority
		#both characters attacked in air: 
		if attackingObjectAttackType == GlobalVariables.AttackType.AERIAL\
		&& attackedObjectAttackType == GlobalVariables.AttackType.AERIAL:
			calculate_hitlag_frames_clashed(interactionObject, attackDamage, hitlagMultiplier)
			interactionObject.is_attacked_calculations(attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, attackingObject.global_position)
		#ground air || air ground collision
		if (attackingObjectAttackType == GlobalVariables.AttackType.AERIAL\
		&& attackedObjectAttackType == GlobalVariables.AttackType.GROUNDED)\
		|| (attackedObjectAttackType == GlobalVariables.AttackType.AERIAL\
		&& attackingObjectAttackType == GlobalVariables.AttackType.GROUNDED):
			calculate_hitlag_frames_clashed(interactionObject, attackDamage, hitlagMultiplier)
			interactionObject.is_attacked_calculations(attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, attackingObject.global_position)
		#ground ground collision check for higher priority (damage percent dealt)
		if attackingObjectAttackType == GlobalVariables.AttackType.GROUNDED\
		&& attackedObjectAttackType == GlobalVariables.AttackType.GROUNDED:
			#if one attack damage is > 9% other attack damage, it is outprioritized, this attack hits
			var isAttackedHandlerParamArray = [attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, attackingObject.global_position]
			var isAttackedHandlerFuncRef = funcref(interactionObject, "is_attacked_calculations")
			HitBoxManager.add_colliding_hitbox(attackingObject, interactionObject, attackDamage, hitlagMultiplier, hitBoxesConnectedCopy, reboundingHitbox, transcendentHitBox, specialHitBoxEffects, isAttackedHandlerFuncRef, isAttackedHandlerParamArray)

func apply_attack_clashed_character_projectile(interactionObject, attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, shieldDamage, shieldStunMultiplier, hitlagMultiplier, reboundingHitbox, transcendentHitBox, specialHitBoxEffects):
	#if projectile belongs to attacker let it pass through 
#	if attackingObject.is_in_group("Projectile"):
#		if attackingObject.parentNode == attackedObject: 
#			return 
#	elif attackedObject.is_in_group("Projectile"):
#		if attackedObject.parentNode == attackingObject: 
#			return 
	#if one attack damage is > 9% other attack damage, it is outprioritized, this attack hits
	var isAttackedHandlerParamArray = [attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, attackingObject.global_position]
	var isAttackedHandlerFuncRef = funcref(interactionObject, "is_attacked_calculations")
	HitBoxManager.add_colliding_hitbox(attackingObject, interactionObject, attackDamage, hitlagMultiplier, hitBoxesConnectedCopy, reboundingHitbox, transcendentHitBox, specialHitBoxEffects, isAttackedHandlerFuncRef, isAttackedHandlerParamArray)

func apply_attack_clashed_projectile_projectile(interactionObject, attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, shieldDamage, shieldStunMultiplier, hitlagMultiplier, reboundingHitbox, transcendentHitBox, specialHitBoxEffects) :
	#if projectile belongs to attacker let it pass through 
#	if attackingObject.is_in_group("Projectile"):
#		if attackingObject.parentNode == attackedObject: 
#			return 
#	elif attackedObject.is_in_group("Projectile"):
#		if attackedObject.parentNode == attackingObject: 
#			return 
	#if one attack damage is > 9% other attack damage, it is outprioritized, this attack hits
	var isAttackedHandlerParamArray = [attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, attackingObject.global_position]
	var isAttackedHandlerFuncRef = funcref(interactionObject, "is_attacked_calculations")
	HitBoxManager.add_colliding_hitbox(attackingObject, interactionObject, attackDamage, hitlagMultiplier, hitBoxesConnectedCopy, reboundingHitbox, transcendentHitBox, specialHitBoxEffects, isAttackedHandlerFuncRef, isAttackedHandlerParamArray)

func calculate_hitlag_frames_clashed(interactionObject, attackDamage, hitlagMultiplier):
	var attackingObjectHitlag = floor((attackDamage*0.65+4)*hitlagMultiplier + (attackingObject.state.hitlagTimer.get_time_left()*60))
	if interactionObject.is_in_group("Character"):
		if interactionObject == attackedObjectArray.front():
			GlobalVariables.start_timer(attackingObject.state.hitlagTimer, attackingObjectHitlag)

func calculate_hitlag_frames_connected(interactionObject, attackDamage, hitlagMultiplier, launchVelocity, weightLaunchVelocity):
	var attackingObjectHitlag = floor((attackDamage*0.65+4)*hitlagMultiplier + (attackingObject.state.hitlagTimer.get_time_left()*60))
	var attackedObjectHitlag = floor((attackDamage*0.65+4)*hitlagMultiplier + (attackedObject.state.hitlagTimer.get_time_left()*60))
	if interactionObject.is_in_group("Character"):
		if interactionObject.currentState == GlobalVariables.CharacterState.SHIELD\
		|| interactionObject.perfectShieldActivated:
			attackingObjectHitlag = floor(attackingObjectHitlag * 0.67)
			attackedObjectHitlag = floor(attackedObjectHitlag * 0.67)
#	attackingObjectHitlag = 200
#	attackedObjectHitlag = 200
	if interactionObject == attackedObjectArray.front():
		GlobalVariables.start_timer(attackingObject.state.hitlagTimer, attackingObjectHitlag)
	elif attackingObject.state.hitlagTimer.get_time_left() < attackingObjectHitlag:
		attackingObject.state.hitlagTimer.set_wait_time(attackingObjectHitlag)

#	print("attackingObjectHitlag " +str(attackingObjectHitlag))
#	print("attackedObjectHitlag " +str(attackedObjectHitlag))
	if launchVelocity == 0 && weightLaunchVelocity == 0:
		interactionObject.is_attacked_handler_no_knockback(attackedObjectHitlag, attackingObject)
	else:
		interactionObject.is_attacked_handler(attackedObjectHitlag, attackingObject)
#	elif attackedObject.is_in_group("Projectile"):
#		attackedObject.state.create_hitlagAttacked_timer(attackedObjectHitlag)

func apply_grab():
	if attackingObject.currentMoveDirection == attackedObject.currentMoveDirection:
		if attackedObject.currentMoveDirection != GlobalVariables.MoveDirection.LEFT:
			attackedObject.currentMoveDirection = GlobalVariables.MoveDirection.LEFT
		elif attackedObject.currentMoveDirection != GlobalVariables.MoveDirection.RIGHT:
			attackedObject.currentMoveDirection = GlobalVariables.MoveDirection.RIGHT
		attackedObject.character.mirror_areas()
	attackedObject.inGrabByCharacter = attackingObject
	attackedObject.change_state(GlobalVariables.CharacterState.INGRAB)

func _on_HitBoxSweetArea_area_entered(area):
	check_hitbox_areas(area, HitBoxType.SWEET)


func _on_HitBoxNeutralArea_area_entered(area):
	check_hitbox_areas(area, HitBoxType.NEUTRAL)


func _on_HitBoxSourArea_area_entered(area):
	check_hitbox_areas(area, HitBoxType.SOUR)
	
func _on_HitBoxSpecial_area_entered(area):
	check_hitbox_areas(area, HitBoxType.SPECIAL)
			
func check_hitbox_areas(area, hitboxType):
	attackingObjectState = attackingObject.currentState
	if area.is_in_group("Hitbox"): 
		if attackingObject != area.get_parent().get_parent().get_parent():
			attackedObject = area.get_parent().get_parent().get_parent()
			if check_item_catch(attackingObject, attackedObject):
				return
			if hitBoxesClashed.empty():
				apply_hitlag(area, GlobalVariables.HitBoxInteractionType.CLASHED)
			if !hitBoxesClashed.has(hitboxType):
				hitBoxesClashed.append(hitboxType)
#			print("hit Hitbox " +str(area.get_parent().attackingObject.name))
	if area.is_in_group("Hurtbox")\
	&& area.get_parent().get_parent() != attackingObject:
		attackedObject = area.get_parent().get_parent()
		if is_projectile_parentNode_interaction(attackingObject, attackedObject):
			return
		if hitBoxesClashed.empty() && hitBoxesConnected.empty():
			apply_hitlag(area, GlobalVariables.HitBoxInteractionType.CONNECTED, true)
		if !hitBoxesConnected.has(hitboxType):
			hitBoxesConnected.append(hitboxType)
		if !attackedObjectArray.has(attackedObject):
			if !attackedObjectArray.empty():
				apply_hitlag(area, GlobalVariables.HitBoxInteractionType.CONNECTED)
			attackedObjectArray.append(attackedObject)
	if area.is_in_group("HurtboxProjectile"):
		attackedObject = area.get_parent()
		if attackedObject != attackingObject\
		&& attackedObject.parentNode != attackingObject:
			if is_projectile_parentNode_interaction(attackingObject, attackedObject):
				return
			if hitBoxesClashed.empty() && hitBoxesConnected.empty():
				apply_hitlag(area, GlobalVariables.HitBoxInteractionType.CONNECTED)
			if !hitBoxesConnected.has(hitboxType):
				hitBoxesConnected.append(hitboxType)
		if !attackedObjectArray.has(attackedObject):
			if !attackedObjectArray.empty():
				apply_hitlag(area, GlobalVariables.HitBoxInteractionType.CONNECTED)
			attackedObjectArray.append(attackedObject)
			
func is_projectile_parentNode_interaction(attackingObject, attackedObject):
	if attackingObject.is_in_group("Projectile"):
		if attackingObject.check_hit_parentNode(attackedObject):
			return attackingObject
	if attackedObject.is_in_group("Projectile"):
		if attackedObject.check_hit_parentNode(attackingObject):
			return attackedObject
	return null
	
func check_item_catch(attackingObject, attackedObject):
	if attackingObject.is_in_group("Projectile")\
		&& attackedObject.is_in_group("Character"):
			if attackingObject.get_parent() != attackedObject:
				if attackedObject.check_item_catch_attack()\
				&& attackingObject.grabAble:
					attackingObject.on_projectile_catch(attackedObject)
			return true
	elif attackedObject.is_in_group("Projectile")\
		&& attackingObject.is_in_group("Character"):
			if attackedObject.get_parent() != attackingObject:
				if attackingObject.check_item_catch_attack()\
				&& attackedObject.grabAble:
					attackedObject.on_projectile_catch(attackingObject)
			return true
	return false
			
func apply_hitlag(hitArea, interactionType, first = false):
		match interactionType:
			GlobalVariables.HitBoxInteractionType.CONNECTED:
				apply_hurtbox_hitlag(first)
			GlobalVariables.HitBoxInteractionType.CLASHED:
				apply_hurtbox_hitlag(first)

func apply_hitbox_hitlag(lagFrames):
	attackedObject.state.create_hitlag_timer(lagFrames)
	attackingObject.state.create_hitlag_timer(lagFrames)

func apply_hurtbox_hitlag(first = false):
	if attackedObject.is_in_group("Character")\
	&& attackingObject.is_in_group("Character"):
		apply_hurtbox_character_character_hitlag(first)
	elif (attackingObject.is_in_group("Projectile")\
	&& attackedObject.is_in_group("Character"))\
	|| (attackingObject.is_in_group("Character")\
	&& attackedObject.is_in_group("Projectile")): 
		apply_hurtbox_character_projectile_hitlag(first)

func apply_hurtbox_character_character_hitlag(first = false):
	if attackedObject != self.get_parent().get_parent() && first:
		if attackingObject.currentState == GlobalVariables.CharacterState.GRAB:
			if attackedObject.currentState == GlobalVariables.CharacterState.GROUND\
			|| attackedObject.currentState == GlobalVariables.CharacterState.AIR\
			|| attackedObject.currentState == GlobalVariables.CharacterState.ATTACKGROUND\
			|| attackedObject.currentState == GlobalVariables.CharacterState.ATTACKAIR\
			|| attackedObject.currentState == GlobalVariables.CharacterState.GRAB\
			|| attackedObject.currentState == GlobalVariables.CharacterState.SPECIALGROUND\
			|| attackedObject.currentState == GlobalVariables.CharacterState.SPECIALAIR\
			|| attackedObject.currentState == GlobalVariables.CharacterState.SHIELD\
			|| attackedObject.currentState == GlobalVariables.CharacterState.ROLL\
			|| attackedObject.currentState == GlobalVariables.CharacterState.SHIELDBREAK\
			|| attackedObject.currentState == GlobalVariables.CharacterState.EDGEGETUP:
				if !attackingObject.grabbedCharacter:
					attackingObject.grabbedCharacter = attackedObject
					attackingObject.apply_grab_animation_step(1)
					apply_grab()
		elif first:
			attackingObject.initLaunchVelocity = attackingObject.velocity
			if attackedObject.currentState == GlobalVariables.CharacterState.SHIELD:
				attackedObject.state.create_hitlag_timer(attackedObject.hitLagFrames)
				attackingObject.state.create_hitlag_timer(attackingObject.hitLagFrames)
			elif attackedObject.currentState == GlobalVariables.CharacterState.GROUND\
			&& attackedObject.state.shieldDropTimer.get_time_left() && attackedObject.perfectShieldFramesLeft > 0:
				attackedObject.perfectShieldActivated = true
				attackedObject.state.create_hitlag_timer(attackedObject.hitLagFrames + (8.0))
				attackingObject.state.create_hitlag_timer(attackingObject.hitLagFrames + (11.0))
			else:
				attackedObject.state.create_hitlag_timer(attackedObject.hitLagFrames)
				attackingObject.state.create_hitlag_timer(attackingObject.hitLagFrames)
		else:
			if attackedObject.currentState == GlobalVariables.CharacterState.SHIELD:
				attackedObject.state.create_hitlag_timer(attackedObject.hitLagFrames)
			elif attackedObject.currentState == GlobalVariables.CharacterState.GROUND\
			&& attackedObject.state.shieldDropTimer.get_time_left() && attackedObject.perfectShieldFramesLeft > 0:
				attackedObject.perfectShieldActivated = true
				attackedObject.state.create_hitlag_timer(attackedObject.hitLagFrames + (8.0))
				attackingObject.state.hitLagTimer.set_wait_time(attackingObject.hitLagFrames + (11.0))
			else:
				attackedObject.state.create_hitlag_timer(attackedObject.hitLagFrames)

func apply_hurtbox_character_projectile_hitlag(first = false):
	if first:
		if attackedObject != self.get_parent().get_parent():
			attackingObject.initLaunchVelocity = attackingObject.velocity
		if attackedObject.is_in_group("Character"):
			if attackedObject.currentState == GlobalVariables.CharacterState.SHIELD:
				attackedObject.state.create_hitlag_timer(attackedObject.hitLagFrames)
				attackingObject.state.create_hitlag_timer(attackingObject.hitLagFrames)
			if attackedObject.currentState == GlobalVariables.CharacterState.GROUND\
			&& attackedObject.state.shieldDropTimer.get_time_left() && attackedObject.perfectShieldFramesLeft > 0:
				attackedObject.perfectShieldActivated = true
				attackedObject.state.create_hitlag_timer(attackedObject.hitLagFrames + (8.0))
				attackingObject.state.create_hitlag_timer(attackingObject.hitLagFrames + (11.0))
			else:
				attackedObject.state.create_hitlag_timer(attackedObject.hitLagFrames)
				attackingObject.state.create_hitlag_timer(attackingObject.hitLagFrames)
		else:
			attackedObject.state.create_hitlag_timer(attackedObject.hitLagFrames)
			attackingObject.state.create_hitlag_timer(attackingObject.hitLagFrames)
	else:
		if attackedObject.is_in_group("Character"):
			if attackedObject.currentState == GlobalVariables.CharacterState.SHIELD:
				attackedObject.state.create_hitlag_timer(attackedObject.hitLagFrames)
			if attackedObject.currentState == GlobalVariables.CharacterState.GROUND\
			&& attackedObject.state.shieldDropTimer.get_time_left() && attackedObject.perfectShieldFramesLeft > 0:
				attackedObject.perfectShieldActivated = true
				attackedObject.state.create_hitlag_timer(attackedObject.hitLagFrames + (8.0))
				attackingObject.state.hitLagTimer.set_wait_time(attackingObject.hitLagFrames + (11.0))
			else:
				attackedObject.state.create_hitlag_timer(attackedObject.hitLagFrames)
		else:
			attackedObject.state.create_hitlag_timer(attackedObject.hitLagFrames)
		

func get_hitbox_by_area(area):
	var sweetSpotArea = sweetSpot.get_parent()
	var sourSpotArea = sourSpot.get_parent()
	var neutralSpotArea = neutralSpot.get_parent()
	var specialSpotArea = specialSpot.get_parent()
	match area:
		sweetSpotArea:
			return HitBoxType.SWEET
		sourSpotArea:
			return HitBoxType.SOUR
		neutralSpotArea:
			return HitBoxType.NEUTRAL
		specialSpotArea:
			return HitBoxType.SPECIAL

func manage_hurtbox_special_interactions_projectile(attackingObject, attackedObject, specialHitBoxEffects, attackDamage):
	if attackedObject.is_in_group("Projectile"):
		var interactionTypeToUse = GlobalVariables.HitBoxInteractionType.CONNECTED
		var attackedObjectInteracted = attackedObject.apply_special_hitbox_effect_attacked(specialHitBoxEffects, attackingObject, attackDamage, interactionTypeToUse)
		if attackedObjectInteracted:
			return true
	return false
