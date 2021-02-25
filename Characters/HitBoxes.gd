extends Node2D

onready var character = get_parent().get_parent()
onready var sweetSpot = $SweetSpot
onready var neutralSpot = $NeutralSpot
onready var sourSpot = $SourSpot
var attackedCharacter = null

enum HitBoxType {SOUR, NEUTRAL, SWEET}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _on_NeutralSpot_area_entered(area):
	if area.is_in_group("Hurtbox"):
		attackedCharacter = area.get_parent().get_parent()
		if attackedCharacter != self.get_parent().get_parent():
			if character.currentState == character.CharacterState.ATTACKGROUND\
			|| character.currentState == character.CharacterState.ATTACKAIR:
				apply_attack(HitBoxType.NEUTRAL)
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
					disable_all_hitboxes()
					character.disableInput = false
					apply_grab(HitBoxType.NEUTRAL)

func disable_all_hitboxes():
	for hitboxArea in self.get_children():
		for hitBoxShape in hitboxArea.get_children():
			hitBoxShape.set_deferred('disabled',true)
		
func apply_attack(hbType):
	var currentHitBoxNumber = character.currentHitBox
	var currentAttackData = (character.attackData[GlobalVariables.CharacterAnimations.keys()[character.currentAttack]])
	var hbString = "neutral_"+String(currentHitBoxNumber)
	match hbType:
		HitBoxType.SOUR:
			hbString = "sour_"+String(currentHitBoxNumber)
		HitBoxType.NEUTRAL:
			hbString = "neutral_"+String(currentHitBoxNumber)
		HitBoxType.SWEET:
			hbString = "sweet_"+String(currentHitBoxNumber)
	print(hbString)
	var attackDamage = currentAttackData["damage_"+hbString]
	var hitStun = currentAttackData["hitStun_"+hbString]
	var launchAngle = deg2rad(currentAttackData["launchAngle_"+hbString])
	var launchVector = Vector2(cos(launchAngle), sin(launchAngle))
	var knockBackScaling = currentAttackData["knockBackGrowth_"+hbString]/100
	var launchVectorX = launchVector.x
	#inverse x launch diretion depending on character position
	if attackedCharacter.global_position.x < character.global_position.x:
		launchVectorX *= -1
	else:
		launchVectorX = abs(launchVectorX)
	var launchVectorY = launchVector.y
	var launchVelocity = currentAttackData["launchVelocity_"+hbString]
	var weightLaunchVelocity = currentAttackData["launchVelocityWeight_"+hbString]
	var shieldStunMultiplier = currentAttackData["shieldStun_multiplier_"+hbString]
#	print(launchVector)
	#if character.currentAttack == GlobalVariables.CharacterAnimations.DASHATTACK:
		#character.disable_pushing_attack()
	disable_all_hitboxes()
	character.create_hitlag_timer()
	if attackedCharacter.currentState == attackedCharacter.CharacterState.SHIELD:
		attackedCharacter.is_attacked_in_shield_handler(attackDamage, shieldStunMultiplier)
	else:
		attackedCharacter.is_attacked_handler(attackDamage, hitStun, launchVectorX, launchVectorY, launchVelocity, weightLaunchVelocity, knockBackScaling)


func apply_grab(hbType):
	character.grabbedCharacter = attackedCharacter
	if character.currentMoveDirection == attackedCharacter.currentMoveDirection:
		if attackedCharacter.currentMoveDirection != attackedCharacter.moveDirection.LEFT:
			attackedCharacter.currentMoveDirection = attackedCharacter.moveDirection.LEFT
		elif attackedCharacter.currentMoveDirection != attackedCharacter.moveDirection.RIGHT:
			attackedCharacter.currentMoveDirection = attackedCharacter.moveDirection.RIGHT
		attackedCharacter.mirror_areas()
	attackedCharacter.is_grabbed_handler(character)

