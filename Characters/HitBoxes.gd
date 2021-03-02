extends Node2D

onready var character = get_parent().get_parent()
onready var sweetSpot = $HitBoxSweetArea/Sweet
onready var neutralSpot = $HitBoxNeutralArea/Neutral
onready var sourSpot = $HitBoxSourArea/Sour
var attackedCharacter = null
var attackedCharacterState = null

var hitBoxesConnected = []

enum HitBoxType {SOUR, NEUTRAL, SWEET}

func _physics_process(delta):
	if !hitBoxesConnected.empty():
		disable_all_hitboxes()
		if character.currentState != character.CharacterState.GRAB:
			var highestHitboxPriority = 0
			var highestHitBox = null
			for hitbox in hitBoxesConnected: 
				match hitbox:
					HitBoxType.SOUR:
						if character.attackData[GlobalVariables.CharacterAnimations.keys()[character.currentAttack] + "_sour"]["priority"] >= highestHitboxPriority:
							highestHitboxPriority = character.attackData[GlobalVariables.CharacterAnimations.keys()[character.currentAttack] + "_sour"]["priority"]
							highestHitBox = HitBoxType.SOUR
					HitBoxType.NEUTRAL:
						if character.attackData[GlobalVariables.CharacterAnimations.keys()[character.currentAttack] + "_neutral"]["priority"] >= highestHitboxPriority:
							highestHitboxPriority = character.attackData[GlobalVariables.CharacterAnimations.keys()[character.currentAttack] + "_neutral"]["priority"]
							highestHitBox = HitBoxType.NEUTRAL
					HitBoxType.SWEET:
						if character.attackData[GlobalVariables.CharacterAnimations.keys()[character.currentAttack] + "_sweet"]["priority"] >= highestHitboxPriority:
							highestHitboxPriority = character.attackData[GlobalVariables.CharacterAnimations.keys()[character.currentAttack] + "_sweet"]["priority"]
							highestHitBox = HitBoxType.SWEET
			if character.currentState == character.CharacterState.ATTACKGROUND\
			|| character.currentState == character.CharacterState.ATTACKAIR:
				apply_attack(highestHitBox)
				#apply_attack(HitBoxType.NEUTRAL)
		hitBoxesConnected.clear()

func disable_all_hitboxes():
	for hitboxArea in self.get_children():
		for hitBoxShape in hitboxArea.get_children():
			hitBoxShape.set_deferred('disabled',true)
		
func apply_attack(hbType):
	var currentHitBoxNumber = character.currentHitBox
	var combinedAttackDataString = character.currentAttack
	match hbType:
		HitBoxType.SOUR:
			combinedAttackDataString = GlobalVariables.CharacterAnimations.keys()[combinedAttackDataString] + "_sour"
		HitBoxType.NEUTRAL:
			combinedAttackDataString = GlobalVariables.CharacterAnimations.keys()[combinedAttackDataString] + "_neutral"
		HitBoxType.SWEET:
			combinedAttackDataString = GlobalVariables.CharacterAnimations.keys()[combinedAttackDataString] + "_sweet"
	#print(combinedAttackDataString)
	var currentAttackData = character.attackData[combinedAttackDataString]
	var attackDamage = currentAttackData["damage_" + String(currentHitBoxNumber)]
	var hitStun = currentAttackData["hitStun_" + String(currentHitBoxNumber)]
	var launchAngle = deg2rad(currentAttackData["launchAngle_" + String(currentHitBoxNumber)])
	var launchVector = Vector2(cos(launchAngle), sin(launchAngle))
	var knockBackScaling = currentAttackData["knockBackGrowth_" + String(currentHitBoxNumber)]/100
	var launchVectorX = launchVector.x
	#inverse x launch diretion depending on character position
	if attackedCharacter.global_position.x < character.global_position.x:
		launchVectorX *= -1
	else:
		launchVectorX = abs(launchVectorX)
	var launchVectorY = launchVector.y
	var launchVelocity = currentAttackData["launchVelocity_" + String(currentHitBoxNumber)]
	var weightLaunchVelocity = currentAttackData["launchVelocityWeight_" + String(currentHitBoxNumber)]
	var shieldStunMultiplier = currentAttackData["shieldStun_multiplier_" + String(currentHitBoxNumber)]
	var shieldDamage = currentAttackData["shield_damage_" + String(currentHitBoxNumber)]
	var isProjectile = false
	if attackedCharacterState == attackedCharacter.CharacterState.SHIELD:
		attackedCharacter.is_attacked_in_shield_handler(attackDamage, shieldStunMultiplier, shieldDamage, isProjectile)
	else:
		attackedCharacter.is_attacked_handler(attackDamage, hitStun, launchVectorX, launchVectorY, launchVelocity, weightLaunchVelocity, knockBackScaling, isProjectile)


func apply_grab():
	if character.currentMoveDirection == attackedCharacter.currentMoveDirection:
		if attackedCharacter.currentMoveDirection != attackedCharacter.moveDirection.LEFT:
			attackedCharacter.currentMoveDirection = attackedCharacter.moveDirection.LEFT
		elif attackedCharacter.currentMoveDirection != attackedCharacter.moveDirection.RIGHT:
			attackedCharacter.currentMoveDirection = attackedCharacter.moveDirection.RIGHT
		attackedCharacter.mirror_areas()
	attackedCharacter.is_grabbed_handler(character)

func _on_HitBoxSweetArea_area_entered(area):
	if area.is_in_group("Hurtbox")\
	&& area.get_parent().get_parent() != character:
		if hitBoxesConnected.empty():
			apply_hitlag(area)
		if !hitBoxesConnected.has(HitBoxType.SWEET):
			hitBoxesConnected.append(HitBoxType.SWEET)


func _on_HitBoxNeutralArea_area_entered(area):
	if area.is_in_group("Hurtbox")\
	&& area.get_parent().get_parent() != character:
		if hitBoxesConnected.empty():
			apply_hitlag(area)
		if !hitBoxesConnected.has(HitBoxType.NEUTRAL):
			hitBoxesConnected.append(HitBoxType.NEUTRAL)


func _on_HitBoxSourArea_area_entered(area):
	if area.is_in_group("Hurtbox")\
	&& area.get_parent().get_parent() != character:
		if hitBoxesConnected.empty():
			apply_hitlag(area)
		if !hitBoxesConnected.has(HitBoxType.SOUR):
			hitBoxesConnected.append(HitBoxType.SOUR)
			
func apply_hitlag(hitArea):
	attackedCharacter = hitArea.get_parent().get_parent()
	attackedCharacterState = attackedCharacter.currentState
	if attackedCharacter != self.get_parent().get_parent():
		if character.currentState == character.CharacterState.ATTACKGROUND\
		|| character.currentState == character.CharacterState.ATTACKAIR:
			character.backUpVelocity = character.velocity
			character.create_hitlag_timer()
			attackedCharacter = hitArea.get_parent().get_parent()
			if attackedCharacterState == attackedCharacter.CharacterState.SHIELD:
				attackedCharacter.create_hitlag_timer()
			else:
				attackedCharacter.create_hitlag_timer_attacked()
		#manage grab if character hit other character hitbox
		elif character.currentState == character.CharacterState.GRAB:
			if attackedCharacter.currentState == attackedCharacter.CharacterState.GROUND\
			|| attackedCharacter.currentState == attackedCharacter.CharacterState.AIR\
			|| attackedCharacter.currentState == attackedCharacter.CharacterState.ATTACKGROUND\
			|| attackedCharacter.currentState == attackedCharacter.CharacterState.ATTACKAIR\
			|| attackedCharacter.currentState == attackedCharacter.CharacterState.GRAB\
			|| attackedCharacter.currentState == attackedCharacter.CharacterState.SPECIALGROUND\
			|| attackedCharacter.currentState == attackedCharacter.CharacterState.SPECIALAIR\
			|| attackedCharacter.currentState == attackedCharacter.CharacterState.SHIELD\
			|| attackedCharacter.currentState == attackedCharacter.CharacterState.ROLL\
			|| attackedCharacter.currentState == attackedCharacter.CharacterState.SHIELDBREAK:
				character.disableInput = false
				character.backUpVelocity = Vector2.ZERO
				character.grabbedCharacter = attackedCharacter
				apply_grab()
