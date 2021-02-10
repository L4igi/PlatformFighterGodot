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
	var currentAttackData = (character.attackData[GlobalVariables.CharacterAnimations.keys()[character.currentAttack]])
	var hbString = "neutral"
	match hbType:
		HitBoxType.SOUR:
			hbString = "sour"
		HitBoxType.NEUTRAL:
			hbString = "neutral"
		HitBoxType.SWEET:
			hbString = "sweet"
	var attackDamage = currentAttackData["damage_"+hbString]
	var hitStun = currentAttackData["hitStun_"+hbString]
	var launchAngle = deg2rad(currentAttackData["launchAngle_"+hbString])
	var launchVector = Vector2(cos(launchAngle), sin(launchAngle))
	var launchVectorX = launchVector.x
	#inverse x launch diretion depending on character position
	if attackedCharacter.global_position.x < character.global_position.x:
		launchVectorX *= -1
	else:
		launchVectorX = abs(launchVectorX)
	var launchVectorY = launchVector.y
	var launchVelocity = currentAttackData["launchVelocity_"+hbString]
#	print(launchVector)
	attackedCharacter.is_attacked_handler(attackDamage, hitStun, launchVectorX, launchVectorY, launchVelocity)

func apply_grab(hbType):
	print("applying grab")
	character.grabbedCharacter = attackedCharacter
	if character.currentMoveDirection == attackedCharacter.currentMoveDirection:
		if attackedCharacter.currentMoveDirection != attackedCharacter.moveDirection.LEFT:
			attackedCharacter.currentMoveDirection = attackedCharacter.moveDirection.LEFT
		elif attackedCharacter.currentMoveDirection != attackedCharacter.moveDirection.RIGHT:
			attackedCharacter.currentMoveDirection = attackedCharacter.moveDirection.RIGHT
		attackedCharacter.mirror_areas()
	attackedCharacter.is_grabbed_handler(character)

