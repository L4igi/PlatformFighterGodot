extends Character

var upspecialInvincibilityFrames = 3.0

onready var arrow = preload("res://Projectiles/Arrow/Arrow.tscn")
onready var bomb = preload("res://Projectiles/Bomb/Bomb.tscn")
onready var chargeShot = preload("res://Projectiles/ChargeShot/ChargeShot.tscn")

var linkDairBounce = 0
var maxLinkDairBounces = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	var file = File.new()
	file.open("res://Characters/Link/linkAttacks.json", file.READ)
	var attacks = JSON.parse(file.get_as_text())
	file.close()
	attackData = attacks.get_result()
	characterIcon = preload("res://Characters/Link/guielements/characterIcon.png")
	characterLogo = preload("res://Characters/Link/guielements/characterLogo.png")
	characterRender = preload("res://Characters/Link/guielements/characterRender.png")
	#air to ground transitions
	moveAirGroundTransition[Globals.CharacterAnimations.DAIR] = 1
	set_base_stats()
	#set state factory according to character
	state_factory = LinkStateFactory.new()
#	if !onSolidGround:
#		change_state(Globals.CharacterState.AIR)
	change_state(Globals.CharacterState.GAMESTART)
	multiPartSmashAttack[Globals.CharacterAnimations.FSMASH] = 1
#	animationPlayer = $AnimatedSprite/AnimationPlayer
	
func set_base_stats():
	weight = 1.7
	baseWalkMaxSpeed = 275
	walkMaxSpeed = 275
	runMaxSpeed = 575
	baseRunMaxSpeed = 575
	jabCombo = 1
	upSpecialSpeed = Vector2(300, 1200)

func apply_attack_animation_steps(step = 0):
	match currentAttack:
		Globals.CharacterAnimations.DAIR: 
			manage_dair(step)
		Globals.CharacterAnimations.DASHATTACK:
			manage_dash_attack(step)
			
func apply_special_animation_steps(step = 0):
	match currentAttack:
		Globals.CharacterAnimations.UPSPECIAL:
			manage_up_special(step)
		Globals.CharacterAnimations.DOWNSPECIAL:
			manage_down_special(step)
		Globals.CharacterAnimations.SIDESPECIAL:
			manage_side_special(step)
		Globals.CharacterAnimations.NSPECIAL:
			manage_neutral_special(step)
	
func manage_dair(step):
	match step:
		0:
			linkDairBounce = 0
			velocity = Vector2.ZERO
			state.gravity_on_off("off")
			disableInputDI = false
		1:
			state.gravity_on_off("on")
			disableInputDI = true
#			animationPlayer.stop(false)
#			state.bufferedAnimation = true
		2:
			if linkDairBounce == maxLinkDairBounces: 
				return
			else:
				link_dair_bounce()
				linkDairBounce += 1
				
func link_dair_bounce():
	velocity.y = -600

func manage_dash_attack(step):
	match step: 
		0: 
			pushingAction = true
		1: 
			pushingAction = false

func manage_up_special(step = 0):
	upSpecialAnimationStep = step
	match step:
		0:
			enableSpecialInput = true
			state.create_invincibility_timer(upspecialInvincibilityFrames)
		1:
			#frame 6 start upwards momentum 
			enableSpecialInput = false
			if !onSolidGround:
				var calculatedUpSpecialSpeed = upSpecialSpeed * Vector2(0,clamp(attackMultiplicator, 1.0, 1.2))
				match currentMoveDirection:
					Globals.MoveDirection.LEFT:
						velocity = Vector2(0, -calculatedUpSpecialSpeed.y)
					Globals.MoveDirection.RIGHT:
						velocity = Vector2(0, -calculatedUpSpecialSpeed.y)
			
func manage_neutral_special(step = 0):
	neutralSpecialAnimationStep = step
	neutralSpecialAnimationStep = step
	match step:
		0:
			edgeGrabShape.set_deferred("disabled", true)
			set_collision_mask_bit(1,true) 
			cancelChargeTransition = null
			enableSpecialInput = true
		1:
			var newArrow = arrow.instance()
			Globals.currentStage.call_deferred("add_child" ,newArrow)
			newArrow.call_deferred("set_base_stats", self, self)
			newArrow.currentCharge = attackMultiplicator 
		
#testing function for different projectilke types
#testing grabable bomb
func manage_down_special(step = 0):
	neutralSpecialAnimationStep = step
	match step:
		0:
			enableSpecialInput = false
		1:
			var newBomb = bomb.instance()
			self.call_deferred("add_child" ,newBomb)
			grabbedItem = newBomb
			newBomb.call_deferred("set_base_stats", self, self)
		2:
			pass
			
func manage_neutral_special_charge_shot(step = 0):
	print("STEP " +str(step))
	neutralSpecialAnimationStep = step
	match step:
		0:
			edgeGrabShape.set_deferred("disabled", true)
			set_collision_mask_bit(1,true) 
			cancelChargeTransition = null
			if (chargingProjectile\
			&& chargingProjectile.currentCharge < chargingProjectile.maxCharge)\
			|| !chargingProjectile:
				enableSpecialInput = true
			else:
				enableSpecialInput = false
		1:
			if cancelChargeTransition:
				enableSpecialInput = false
				state.play_attack_animation("cancel_charge")
			elif !chargingProjectile:
				var newChargeShot = chargeShot.instance()
				self.call_deferred("add_child" ,newChargeShot)
				newChargeShot.call_deferred("set_base_stats", self, self)
			else:
				if !chargingProjectile.check_fully_charged(0):
					chargingProjectile.change_state(Globals.ProjectileState.CHARGE)
		2:
			if chargingProjectile && !chargingProjectile.check_fully_charged(1):
				animationPlayer.stop(false)
#			else:
#				chargingProjectile.shoot_charge_projectile()
			
func manage_side_special(step = 0):
	sideSpecialAnimationStep = step
	match step:
		0:
#			if onSolidGround: 
#				velocity.x = 0
			enableSpecialInput = false
		1:
			pass
		2:
			pass
			
func change_to_special_state():
	var changeToState = null
		#changes for each character, if item is held and this moves would spawn new item throw current item instead
	if onSolidGround:
		if grabbedItem && get_input_direction_y() > 0:
			thrownFromGrabbedItemSpawnMove = true
			changeToState = Globals.CharacterState.ATTACKGROUND
		else:
			changeToState = Globals.CharacterState.SPECIALGROUND
	else:
		if grabbedItem && get_input_direction_y() > 0:
			thrownFromGrabbedItemSpawnMove = true
			changeToState = Globals.CharacterState.ATTACKAIR
		else:
			changeToState = Globals.CharacterState.SPECIALAIR
	return changeToState

func initialize_special_animation_steps():
	match currentAttack:
		Globals.CharacterAnimations.UPSPECIAL:
			moveAirGroundTransition[Globals.CharacterAnimations.UPSPECIAL] = 1
			moveGroundAirTransition[Globals.CharacterAnimations.UPSPECIAL] = 1
		Globals.CharacterAnimations.NSPECIAL:
			moveAirGroundTransition[Globals.CharacterAnimations.NSPECIAL] = 1
			moveGroundAirTransition[Globals.CharacterAnimations.NSPECIAL] = 1
		Globals.CharacterAnimations.DOWNSPECIAL:
			moveAirGroundTransition[Globals.CharacterAnimations.DOWNSPECIAL] = 1
			moveGroundAirTransition[Globals.CharacterAnimations.DOWNSPECIAL] = 1
		Globals.CharacterAnimations.SIDESPECIAL:
			moveAirGroundTransition[Globals.CharacterAnimations.SIDESPECIAL] = 1
			moveGroundAirTransition[Globals.CharacterAnimations.SIDESPECIAL] = 1

func finish_special_animation(step):
	match currentAttack:
		Globals.CharacterAnimations.UPSPECIAL:
			moveAirGroundTransition.erase(Globals.CharacterAnimations.UPSPECIAL)
			moveGroundAirTransition.erase(Globals.CharacterAnimations.UPSPECIAL)
			change_state(Globals.CharacterState.HELPLESS)
			return
		Globals.CharacterAnimations.NSPECIAL:
			moveAirGroundTransition.erase(Globals.CharacterAnimations.NSPECIAL)
			moveGroundAirTransition.erase(Globals.CharacterAnimations.NSPECIAL)
		Globals.CharacterAnimations.DOWNSPECIAL:
			moveAirGroundTransition.erase(Globals.CharacterAnimations.DOWNSPECIAL)
			moveGroundAirTransition.erase(Globals.CharacterAnimations.DOWNSPECIAL)
		Globals.CharacterAnimations.SIDESPECIAL:
			moveAirGroundTransition.erase(Globals.CharacterAnimations.SIDESPECIAL)
			moveGroundAirTransition.erase(Globals.CharacterAnimations.SIDESPECIAL)
	.finish_special_animation(step)


func manage_throw_item_special_moves():
	currentAttack = Globals.CharacterAnimations.THROWITEMFORWARD
	state.play_attack_animation("throw_item_forward")


func check_move_connected_interaction():
	match currentAttack:
		Globals.CharacterAnimations.DAIR:
			manage_dair(2)

