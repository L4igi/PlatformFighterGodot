extends Node2D

onready var attackingObject = null
onready var sweetSpot = $HitBoxSweetArea/Sweet
onready var neutralSpot = $HitBoxNeutralArea/Neutral
onready var sourSpot = $HitBoxSourArea/Sour
var attackedObject = null
var attackedObjectState = null
var attackDataEnum = null

var hitBoxesConnected = []

enum HitBoxType {SOUR, NEUTRAL, SWEET}

func _ready():
	attackingObject = get_parent().get_parent()
	if attackingObject.is_in_group("Character"):
		attackDataEnum = GlobalVariables.CharacterAnimations

func _process(delta):
	if !hitBoxesConnected.empty():
		disable_all_hitboxes()
		if attackingObject.currentState != GlobalVariables.CharacterState.GRAB:
			var highestHitboxPriority = 0
			var highestHitBox = null
			for hitbox in hitBoxesConnected: 
				match hitbox:
					HitBoxType.SOUR:
						if attackingObject.attackData[attackDataEnum.keys()[attackingObject.currentAttack] + "_sour"]["priority"] >= highestHitboxPriority:
							highestHitboxPriority = attackingObject.attackData[attackDataEnum.keys()[attackingObject.currentAttack] + "_sour"]["priority"]
							highestHitBox = HitBoxType.SOUR
					HitBoxType.NEUTRAL:
						if attackingObject.attackData[attackDataEnum.keys()[attackingObject.currentAttack] + "_neutral"]["priority"] >= highestHitboxPriority:
							highestHitboxPriority = attackingObject.attackData[attackDataEnum.keys()[attackingObject.currentAttack] + "_neutral"]["priority"]
							highestHitBox = HitBoxType.NEUTRAL
					HitBoxType.SWEET:
						if attackingObject.attackData[attackDataEnum.keys()[attackingObject.currentAttack] + "_sweet"]["priority"] >= highestHitboxPriority:
							highestHitboxPriority = attackingObject.attackData[attackDataEnum.keys()[attackingObject.currentAttack] + "_sweet"]["priority"]
							highestHitBox = HitBoxType.SWEET
			apply_attack(highestHitBox)
		hitBoxesConnected.clear()

func disable_all_hitboxes():
	for hitboxArea in self.get_children():
		for hitBoxShape in hitboxArea.get_children():
			hitBoxShape.set_deferred('disabled',true)
		
func apply_attack(hbType):
	var currentHitBoxNumber = attackingObject.currentHitBox
	var combinedAttackDataString = attackingObject.currentAttack
	match hbType:
		HitBoxType.SOUR:
			combinedAttackDataString = attackDataEnum.keys()[combinedAttackDataString] + "_sour"
		HitBoxType.NEUTRAL:
			combinedAttackDataString = attackDataEnum.keys()[combinedAttackDataString] + "_neutral"
		HitBoxType.SWEET:
			combinedAttackDataString = attackDataEnum.keys()[combinedAttackDataString] + "_sweet"
	var currentAttackData = attackingObject.attackData[combinedAttackDataString]
	var attackDamage = currentAttackData["damage_" + String(currentHitBoxNumber)]
	#calculate damage if charged smash attack
	if attackingObject.is_in_group("Character"):
		attackDamage *= attackingObject.smashAttackMultiplier
	var hitStun = currentAttackData["hitStun_" + String(currentHitBoxNumber)]
	var launchAngle = deg2rad(currentAttackData["launchAngle_" + String(currentHitBoxNumber)])
	var launchVector = Vector2(cos(launchAngle), sin(launchAngle))
	var knockBackScaling = currentAttackData["knockBackGrowth_" + String(currentHitBoxNumber)]/100
	var launchVectorInversion = false
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
	#upate hitlag timer wait time after connecting hitbox was chosen 
	#(d * 0.65 + 6) * m.
	calculate_hitlag_frames(attackDamage, hitlagMultiplier)
	if attackedObject.is_in_group("Character"):
		if attackedObjectState == GlobalVariables.CharacterState.SHIELD:
			attackedObject.is_attacked_in_shield_handler(attackDamage, shieldStunMultiplier, shieldDamage, isProjectile, attackingObject.global_position)
		elif attackedObject.perfectShieldActivated:
			attackedObject.is_attacked_handler_perfect_shield()
		else:
			attackedObject.is_attacked_handler(attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, attackingObject.global_position)
	else:
		attackedObject.is_attacked_handler(attackDamage, hitStun, launchAngle, launchVectorInversion, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile, attackingObject.global_position)

func calculate_hitlag_frames(attackDamage, hitlagMultiplier):
	var attackingObjectHitlag = floor((attackDamage*0.65+4)*hitlagMultiplier + (attackingObject.state.hitlagTimer.get_time_left()*60))
	var attackedObjectHitlag = floor((attackDamage*0.65+4)*hitlagMultiplier + (attackedObject.state.hitlagAttackedTimer.get_time_left()*60))
	if attackedObject.is_in_group("Character"):
		if attackedObjectState == GlobalVariables.CharacterState.SHIELD\
		|| attackedObject.perfectShieldActivated:
			attackingObjectHitlag = floor(attackingObjectHitlag * 0.67)
			attackedObjectHitlag = floor(attackedObjectHitlag * 0.67)
		attackingObject.state.start_timer(attackingObject.state.hitlagTimer, attackingObjectHitlag)
	attackedObject.state.start_timer(attackedObject.state.hitlagAttackedTimer, attackedObjectHitlag)
#	print("calculated hitlag frames character "+ str(characterHitlag))
#	print("calculated hitlag frames attackedcharacter "+ str(attackedCharacterHitlag))

func apply_grab():
	if attackingObject.currentMoveDirection == attackedObject.currentMoveDirection:
		if attackedObject.currentMoveDirection != GlobalVariables.MoveDirection.LEFT:
			attackedObject.currentMoveDirection = GlobalVariables.MoveDirection.LEFT
		elif attackedObject.currentMoveDirection != GlobalVariables.MoveDirection.RIGHT:
			attackedObject.currentMoveDirection = GlobalVariables.MoveDirection.RIGHT
		attackedObject.state.mirror_areas()
	attackedObject.inGrabByCharacter = attackingObject
	attackedObject.change_state(GlobalVariables.CharacterState.INGRAB)

func _on_HitBoxSweetArea_area_entered(area):
	check_hitbox_areas(area, HitBoxType.SWEET)


func _on_HitBoxNeutralArea_area_entered(area):
	check_hitbox_areas(area, HitBoxType.NEUTRAL)


func _on_HitBoxSourArea_area_entered(area):
	check_hitbox_areas(area, HitBoxType.SOUR)
			
func check_hitbox_areas(area, hitboxType):
	if area.is_in_group("Hitbox"): 
		if attackingObject != area.get_parent().attackingObject: 
			print("hit Hitbox " +str(area.get_parent().attackingObject.name))
	if area.is_in_group("Hurtbox")\
	&& area.get_parent().get_parent() != attackingObject:
		if hitBoxesConnected.empty():
			apply_hitlag(area)
		if !hitBoxesConnected.has(hitboxType):
			hitBoxesConnected.append(hitboxType)
			
func apply_hitlag(hitArea):
	attackedObject = hitArea.get_parent().get_parent()
	attackedObjectState = attackedObject.currentState
	if attackedObject != self.get_parent().get_parent():
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
				attackingObject.grabbedCharacter = attackedObject
				attackingObject.apply_grab_animation_step(1)
				apply_grab()
		else:
			attackingObject.initLaunchVelocity = attackingObject.velocity
			attackedObject = hitArea.get_parent().get_parent()
			if attackedObjectState == GlobalVariables.CharacterState.SHIELD:
				attackedObject.character_attacked_shield_handler(attackedObject.hitLagFrames)
				attackingObject.state.create_hitlag_timer(attackingObject.hitLagFrames)
			elif attackedObjectState == GlobalVariables.CharacterState.GROUND\
			&& attackedObject.state.shieldDropTimer.get_time_left() && attackedObject.perfectShieldFramesLeft > 0:
				attackedObject.perfectShieldActivated = true
				attackedObject.character_attacked_handler(attackedObject.hitLagFrames + (8.0))
				attackingObject.state.create_hitlag_timer(attackingObject.hitLagFrames + (11.0))
			else:
				attackedObject.character_attacked_handler(attackedObject.hitLagFrames)
				attackingObject.state.create_hitlag_timer(attackingObject.hitLagFrames)
		#manage grab if character hit other character hitbox

func apply_character_character_hitlag():
	pass
				
