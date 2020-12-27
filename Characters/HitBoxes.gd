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


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_NeutralSpot_area_entered(area):
	if area.is_in_group("Hurtbox"):
		attackedCharacter = area.get_parent().get_parent()
		if attackedCharacter != self.get_parent().get_parent():
			apply_attack(HitBoxType.NEUTRAL)

		
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
	print(launchVector)
	attackedCharacter.is_attacked_handler(attackDamage, hitStun, launchVectorX, launchVectorY, launchVelocity)



