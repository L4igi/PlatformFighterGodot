extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var character = get_parent().get_parent()
onready var sweetSpot = $SweetSpot
onready var neutralSpot = $NeutralSpot
onready var sourSpot = $SourSpot
var attackedCharacter = null

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
			apply_attack()
		#apply damage
		#apply hitstun
		#apply launch velocity
		
func apply_attack():
	match character.currentAttack:
		GlobalVariables.CharacterAnimations.JAB1:
			var currentAttackData = (character.attackData[GlobalVariables.CharacterAnimations.keys()[character.currentAttack]])
			#print(currentAttackData)
			var attackDamage = currentAttackData["damage"]
			var hitStun = currentAttackData["hitStun"]
			var launchVectorX = currentAttackData["launchVectorX"]
			#inverse x launch diretion depending on character position
			if attackedCharacter.global_position.x < character.global_position.x:
				launchVectorX = -1
			else:
				launchVectorX = 1
			var launchVectorY = currentAttackData["launchVectorY"]
			var launchVelocity = currentAttackData["launchVelocity"]
			attackedCharacter.is_attacked_handler(attackDamage, hitStun, launchVectorX, launchVectorY, launchVelocity)
		GlobalVariables.CharacterAnimations.NAIR:
			pass
