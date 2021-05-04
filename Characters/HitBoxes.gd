extends Node2D

onready var attackingObject = null
var attackingObjectState = null
onready var sweetSpot = $HitBoxSweetArea/Sweet
onready var neutralSpot = $HitBoxNeutralArea/Neutral
onready var sourSpot = $HitBoxSourArea/Sour
onready var specialSpot = $HitBoxSpecial/Special
var attackedObjectArray = {}
var connectedObjectArray = {}
var clashedObjectArray = {}

var hitBoxesConnected = []
var hitBoxesConnectedCopy = []

var hitBoxesClashed = []

enum HitBoxType {SOUR, NEUTRAL, SWEET, SPECIAL}

func _ready():
	attackingObject = get_parent().get_parent()

func _process(delta):
	if !clashedObjectArray.empty() || !connectedObjectArray.empty():
		attackingObject.toggle_all_hitboxes("off")
	if !clashedObjectArray.empty():
		process_clashed_hitboxes(GlobalVariables.HitBoxInteractionType.CLASHED, clashedObjectArray)
		#remove all successfully clashed attacks if connected from connected array
		remove_clashed_from_connected()
	if !connectedObjectArray.empty():
		process_connected_hitboxes(GlobalVariables.HitBoxInteractionType.CONNECTED, connectedObjectArray)
	connectedObjectArray.clear()
	clashedObjectArray.clear()

func remove_clashed_from_connected():
	for object in clashedObjectArray.keys():
		connectedObjectArray.erase(object)

func process_connected_hitboxes(interactionType, objectArray):
	for object in objectArray.keys():
		object.toggle_all_hitboxes("off")
		if object.is_in_group("Character"):
			if attackingObject.currentState != GlobalVariables.CharacterState.GRAB:
				HitBoxHurtBoxManager.add_connected_hurtbox(attackingObject, object, objectArray.get(object))
		elif object.is_in_group("Projectile"):
			HitBoxHurtBoxManager.add_connected_hurtbox(attackingObject, object, objectArray.get(object))
		set_hitbox_data(object, objectArray.get(object), interactionType)
		
func process_clashed_hitboxes(interactionType, objectArray):
	for object in objectArray.keys():
		set_hitbox_data(object, objectArray.get(object), interactionType)
	
func set_hightest_priority_hitbox(object, hitbox, currentHighestHitbox = null):
	var highestMatchedHitBox = null
	var highestMatchedHitbox = 0
	match hitbox:
		HitBoxType.SOUR:
			highestMatchedHitbox = object.attackData[object.attackDataEnum.keys()[object.currentAttack] + "_sour"]["priority"]
			highestMatchedHitBox = HitBoxType.SOUR
		HitBoxType.NEUTRAL:
			highestMatchedHitbox = object.attackData[object.attackDataEnum.keys()[object.currentAttack] + "_neutral"]["priority"]
			highestMatchedHitBox = HitBoxType.NEUTRAL
		HitBoxType.SWEET:
			highestMatchedHitbox = object.attackData[object.attackDataEnum.keys()[object.currentAttack] + "_sweet"]["priority"]
			highestMatchedHitBox = HitBoxType.SWEET
		HitBoxType.SPECIAL:
			highestMatchedHitbox = object.attackData[object.attackDataEnum.keys()[object.currentAttack] + "_special"]["priority"]
			highestMatchedHitBox = HitBoxType.SPECIAL
	if (currentHighestHitbox && highestMatchedHitbox >= currentHighestHitbox)\
	|| !currentHighestHitbox:
		return highestMatchedHitBox
	return currentHighestHitbox
	
func get_attackData_match_highest_hitbox_json_data(object, hbType):
	var combinedAttackDataString = object.currentAttack
	match hbType:
		HitBoxType.SOUR:
			combinedAttackDataString = object.attackDataEnum.keys()[combinedAttackDataString] + "_sour"
		HitBoxType.NEUTRAL:
			combinedAttackDataString = object.attackDataEnum.keys()[combinedAttackDataString] + "_neutral"
		HitBoxType.SWEET:
			combinedAttackDataString = object.attackDataEnum.keys()[combinedAttackDataString] + "_sweet"
		HitBoxType.SPECIAL:
			combinedAttackDataString = object.attackDataEnum.keys()[combinedAttackDataString] + "_special"
	return object.attackData[combinedAttackDataString]
		
func set_hitbox_data(attackedObject, hbType, interactionType):
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
	var hitlagMultiplier = currentAttackData["hitlag_multiplier_" + String(currentHitBoxNumber)]
	var specialHitBoxEffects = []
	for effect in currentAttackData.get("effects_" +String(currentHitBoxNumber)).values():
		specialHitBoxEffects.append(GlobalVariables.SpecialHitboxType.keys().find(effect))
	match interactionType:
		GlobalVariables.HitBoxInteractionType.CONNECTED:
			HitBoxHurtBoxManager.add_connected_hitbox(attackingObject, hbType, attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, shieldStunMultiplier, shieldDamage, specialHitBoxEffects, hitlagMultiplier)
		GlobalVariables.HitBoxInteractionType.CLASHED:
			apply_attack_clashed(attackedObject, attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, shieldDamage, shieldStunMultiplier, hitlagMultiplier, reboundingHitbox, transcendentHitBox, specialHitBoxEffects)

func apply_attack_clashed(attackedObject, attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling,  shieldDamage, shieldStunMultiplier, hitlagMultiplier, reboundingHitbox, transcendentHitBox, specialHitBoxEffects):
	if attackedObject.is_in_group("Character")\
	&& attackingObject.is_in_group("Character"):
		apply_attack_clashed_character_character(attackedObject, attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling,  shieldDamage, shieldStunMultiplier, hitlagMultiplier, reboundingHitbox, transcendentHitBox, specialHitBoxEffects)
	elif (attackingObject.is_in_group("Projectile")\
	&& attackedObject.is_in_group("Character"))\
	|| (attackingObject.is_in_group("Character")\
	&& attackedObject.is_in_group("Projectile")): 
		apply_attack_clashed_character_projectile(attackedObject, attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling,  shieldDamage, shieldStunMultiplier, hitlagMultiplier, reboundingHitbox, transcendentHitBox, specialHitBoxEffects)
	#projectile projectile interaction 
	elif attackedObject.is_in_group("Projectile")\
	&& attackingObject.is_in_group("Projectile"):
		apply_attack_clashed_projectile_projectile(attackedObject, attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling,  shieldDamage, shieldStunMultiplier, hitlagMultiplier, reboundingHitbox, transcendentHitBox, specialHitBoxEffects) 
			
			
func apply_attack_clashed_character_character(attackedObject, attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling,  shieldDamage, shieldStunMultiplier, hitlagMultiplier, reboundingHitbox, transcendentHitBox, specialHitBoxEffects):
		var attackingObjectAttackType = GlobalVariables.match_attack_type_character(attackingObject, attackingObject.currentAttack)
		var attackedObjectAttackType = GlobalVariables.match_attack_type_character(attackedObject, attackedObject.currentAttack)
		#match interaction cases
		#check case if attack has Transcendent priority
		#both characters attacked in air: 
		if attackingObjectAttackType == GlobalVariables.AttackType.AERIAL\
		&& attackedObjectAttackType == GlobalVariables.AttackType.AERIAL:
			attackingObject.multiObjectsConnected = true
			attackedObject.multiObjectsConnected = true
			clashedObjectArray.erase(attackedObject)
		#ground air || air ground collision
		if (attackingObjectAttackType == GlobalVariables.AttackType.AERIAL\
		&& attackedObjectAttackType == GlobalVariables.AttackType.GROUNDED)\
		|| (attackedObjectAttackType == GlobalVariables.AttackType.AERIAL\
		&& attackingObjectAttackType == GlobalVariables.AttackType.GROUNDED):
			clashedObjectArray.erase(attackedObject)
		#ground ground collision check for higher priority (damage percent dealt)
		if attackingObjectAttackType == GlobalVariables.AttackType.GROUNDED\
		&& attackedObjectAttackType == GlobalVariables.AttackType.GROUNDED:
			#if one attack damage is > 9% other attack damage, it is outprioritized, this attack hits
			var isAttackedHandlerParamArray = [attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling,  attackingObject.global_position]
			var isAttackedHandlerFuncRef = funcref(attackedObject, "is_attacked_calculations")
			HitBoxManager.add_colliding_hitbox(attackingObject, attackedObject, attackDamage, hitlagMultiplier, hitBoxesConnectedCopy, reboundingHitbox, transcendentHitBox, specialHitBoxEffects, isAttackedHandlerFuncRef, isAttackedHandlerParamArray)

func apply_attack_clashed_character_projectile(attackedObject, attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling,  shieldDamage, shieldStunMultiplier, hitlagMultiplier, reboundingHitbox, transcendentHitBox, specialHitBoxEffects):
	var isAttackedHandlerParamArray = [attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling,  attackingObject.global_position]
	var isAttackedHandlerFuncRef = funcref(attackedObject, "is_attacked_calculations")
	HitBoxManager.add_colliding_hitbox(attackingObject, attackedObject, attackDamage, hitlagMultiplier, hitBoxesConnectedCopy, reboundingHitbox, transcendentHitBox, specialHitBoxEffects, isAttackedHandlerFuncRef, isAttackedHandlerParamArray)

func apply_attack_clashed_projectile_projectile(attackedObject, attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling,  shieldDamage, shieldStunMultiplier, hitlagMultiplier, reboundingHitbox, transcendentHitBox, specialHitBoxEffects) :
	var isAttackedHandlerParamArray = [attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling,  attackingObject.global_position]
	var isAttackedHandlerFuncRef = funcref(attackedObject, "is_attacked_calculations")
	HitBoxManager.add_colliding_hitbox(attackingObject, attackedObject, attackDamage, hitlagMultiplier, hitBoxesConnectedCopy, reboundingHitbox, transcendentHitBox, specialHitBoxEffects, isAttackedHandlerFuncRef, isAttackedHandlerParamArray)


func apply_grab(attackedObject):
	if attackingObject.currentMoveDirection == attackedObject.currentMoveDirection:
		if attackedObject.currentMoveDirection != GlobalVariables.MoveDirection.LEFT:
			attackedObject.currentMoveDirection = GlobalVariables.MoveDirection.LEFT
		elif attackedObject.currentMoveDirection != GlobalVariables.MoveDirection.RIGHT:
			attackedObject.currentMoveDirection = GlobalVariables.MoveDirection.RIGHT
		attackedObject.mirror_areas()
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
	var attackedObject = null
	attackingObjectState = attackingObject.currentState
	if area.is_in_group("Hitbox"): 
		if attackingObject != area.get_parent().get_parent().get_parent(): 
			attackedObject = area.get_parent().get_parent().get_parent()
			if check_item_catch(attackingObject, attackedObject):
				return 
			if !clashedObjectArray.has(attackedObject):
				clashedObjectArray[attackedObject] = set_hightest_priority_hitbox(attackingObject, hitboxType)
			else:
				clashedObjectArray[attackedObject] = set_hightest_priority_hitbox(attackingObject, hitboxType, clashedObjectArray[attackedObject])
			attackingObject.state.create_hitlag_timer(attackingObject.hitLagFrames)
	elif area.is_in_group("Hurtbox")\
	&& area.get_parent().get_parent() != attackingObject:
		attackedObject = area.get_parent().get_parent()
		if is_projectile_parentNode_interaction(attackingObject, attackedObject):
			return 
		if check_character_grab(attackedObject):
			return 
		if !connectedObjectArray.has(attackedObject):
			connectedObjectArray[attackedObject] = set_hightest_priority_hitbox(attackingObject, hitboxType)
		else:
			connectedObjectArray[attackedObject] = set_hightest_priority_hitbox(attackingObject, hitboxType, connectedObjectArray[attackedObject])
#		apply_hitlag(attackedObject)
		apply_hurtbox_hitlag(attackedObject)
	elif area.is_in_group("HurtboxProjectile"):
		attackedObject = area.get_parent()
		if is_projectile_parentNode_interaction(attackingObject, attackedObject):
			return 
		if !connectedObjectArray.has(attackedObject):
			connectedObjectArray[attackedObject] = set_hightest_priority_hitbox(attackingObject, hitboxType)
		else:
			connectedObjectArray[attackedObject] = set_hightest_priority_hitbox(attackingObject, hitboxType, connectedObjectArray[attackedObject])
#		apply_hitlag(attackedObject)
		apply_hurtbox_hitlag(attackedObject)
			
func is_projectile_parentNode_interaction(attackingObject, attackedObject):
	if attackingObject.is_in_group("Projectile"):
		if attackingObject.check_hit_parentNode(attackedObject):
			return true
	if attackedObject.is_in_group("Projectile"):
		if attackedObject.check_hit_parentNode(attackingObject):
			return true
	return false
	
func check_item_catch(attackingObject, attackedObject):
	if attackingObject.is_in_group("Projectile")\
		&& attackedObject.is_in_group("Character"):
			if attackingObject.get_parent() != attackedObject:
				if attackedObject.check_item_catch_attack()\
				&& attackingObject.grabAble:
					attackingObject.on_projectile_catch(attackedObject)
					return true
				elif attackingObject.parentNode == attackedObject: 
					return true
	elif attackedObject.is_in_group("Projectile")\
		&& attackingObject.is_in_group("Character"):
			if attackedObject.get_parent() != attackingObject:
				if attackingObject.check_item_catch_attack()\
				&& attackedObject.grabAble:
					attackedObject.on_projectile_catch(attackingObject)
					return true
				elif attackedObject.parentNode == attackingObject: 
					return true
	return false
	
func check_character_grab(attackedObject):
	if clashedObjectArray.has(attackedObject):
		return false
	if attackingObject.is_in_group("Character")\
	&& attackedObject.is_in_group("Character")\
	&& attackingObject.currentState == GlobalVariables.CharacterState.GRAB:
		if attackedObject.currentState == GlobalVariables.CharacterState.GROUND\
		|| attackedObject.currentState == GlobalVariables.CharacterState.AIR\
		|| attackedObject.currentState == GlobalVariables.CharacterState.ATTACKGROUND\
		|| attackedObject.currentState == GlobalVariables.CharacterState.ATTACKAIR\
		|| attackedObject.currentState == GlobalVariables.CharacterState.SPECIALGROUND\
		|| attackedObject.currentState == GlobalVariables.CharacterState.SPECIALAIR\
		|| attackedObject.currentState == GlobalVariables.CharacterState.SHIELD\
		|| attackedObject.currentState == GlobalVariables.CharacterState.ROLL\
		|| attackedObject.currentState == GlobalVariables.CharacterState.SHIELDBREAK\
		|| attackedObject.currentState == GlobalVariables.CharacterState.EDGEGETUP:
			print(attackedObject.currentState)
			attackingObject.grabbedCharacter = attackedObject
			attackingObject.apply_grab_animation_step(1)
			apply_grab(attackedObject)
			return true
	return false
	
func apply_hitlag(attackedObject):
	attackedObject.state.create_hitlag_timer(attackedObject.hitLagFrames)
	attackingObject.state.create_hitlag_timer(attackingObject.hitLagFrames)

func apply_hurtbox_hitlag(attackedObject, firstCall = false):
	if attackingObject.is_in_group("Character"):
		if attackingObject.currentState == GlobalVariables.CharacterState.GRAB:
			return 
	if attackedObject.is_in_group("Character"):
		if attackedObject.currentState == GlobalVariables.CharacterState.SHIELD\
		|| attackedObject.currentState == GlobalVariables.CharacterState.SHIELDSTUN:
			attackingObject.state.create_hitlag_timer(attackingObject.hitLagFrames)
			attackedObject.state.create_hitlag_timer(attackedObject.hitLagFrames)
		elif attackedObject.currentState == GlobalVariables.CharacterState.GROUND\
		&& attackedObject.state.shieldDropTimer.get_time_left() && attackedObject.perfectShieldFramesLeft > 0:
			attackedObject.perfectShieldActivated = true
			attackedObject.state.create_hitlag_timer(attackedObject.hitLagFrames + (8.0))
			attackingObject.state.create_hitlag_timer(attackingObject.hitLagFrames + (11.0))
		else:
			attackingObject.state.create_hitlag_timer(attackingObject.hitLagFrames)
			attackedObject.state.create_hitlag_timer(attackedObject.hitLagFrames)
	else:
		attackingObject.state.create_hitlag_timer(attackingObject.hitLagFrames)
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
