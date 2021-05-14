extends Character

var upspecialInvincibilityFrames = 3.0

onready var fireBall = preload("res://Projectiles/FireBall/FireBall.tscn")
onready var bomb = preload("res://Projectiles/Bomb/Bomb.tscn")
onready var chargeShot = preload("res://Projectiles/ChargeShot/ChargeShot.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	characterIcon = preload("res://Characters/Mario/guielements/characterIcon.png")
	characterLogo = preload("res://Characters/Mario/guielements/characterLogo.png")
	#air to ground transitions
	moveAirGroundTransition[Globals.CharacterAnimations.DAIR] = 1
	set_base_stats()
	#set state factory according to character
	state_factory = MarioStateFactory.new()
#	if !onSolidGround:
#		change_state(Globals.CharacterState.AIR)
	change_state(Globals.CharacterState.GAMESTART)
#	animationPlayer = $AnimatedSprite/AnimationPlayer
	
func set_base_stats():
	weight = 1.5
	baseWalkMaxSpeed = 300
	walkMaxSpeed = 300
	runMaxSpeed = 600
	baseRunMaxSpeed = 600
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
			manage_neutral_special_charge_shot(step)
	
func manage_dair(step):
	match step:
		0:
			velocity = Vector2.ZERO
			state.gravity_on_off("off")
			disableInputDI = false
		1:
			state.gravity_on_off("on")
			animationPlayer.stop(false)
			state.bufferedAnimation = true

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
			enableSpecialInput = false
			state.create_invincibility_timer(upspecialInvincibilityFrames)
		1:
			#frame 6 start upwards momentum 
			enableSpecialInput = true
			match currentMoveDirection:
				Globals.MoveDirection.LEFT:
					velocity = Vector2(-upSpecialSpeed.x, -upSpecialSpeed.y)
				Globals.MoveDirection.RIGHT:
					velocity = Vector2(upSpecialSpeed.x, -upSpecialSpeed.y)
			
func manage_neutral_special(step = 0):
	neutralSpecialAnimationStep = step
	match step:
		0:
			enableSpecialInput = false
		1:
			var newFireBall = fireBall.instance()
#			newFireBall.set_base_stats(self, self)
			Globals.currentStage.call_deferred("add_child" ,newFireBall)
			newFireBall.call_deferred("set_base_stats", self, self)
		2:
			pass
		
#testing function for different projectilke types
#testing grabable bomb
func manage_neutral_special_bomb(step = 0):
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
		
func manage_down_special(step = 0):
	downSpecialAnimationStep = step
	match step:
		0:
			enableSpecialInput = true
		1:
			disableInputDI = false
			enableSpecialInput = false
			edgeGrabShape.set_deferred("disabled", false)
			set_collision_mask_bit(1,true) 
		2:
			pass
			
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
		if grabbedItem && get_input_direction_x() == 0 && get_input_direction_y() == 0:
			changeToState = Globals.CharacterState.ATTACKGROUND
		else:
			changeToState = Globals.CharacterState.SPECIALGROUND
	else:
		if grabbedItem && get_input_direction_x() == 0 && get_input_direction_y() == 0:
			changeToState = Globals.CharacterState.ATTACKAIR
		else:
			changeToState = Globals.CharacterState.SPECIALAIR
	return changeToState

#func check_special_animation_steps():
#	match currentAttack:
#		Globals.CharacterAnimations.UPSPECIAL:
#			match upSpecialAnimationStep:
#				0:
#					moveAirGroundTransition[Globals.CharacterAnimations.UPSPECIAL] = 1
#					moveGroundAirTransition[Globals.CharacterAnimations.UPSPECIAL] = 1
#				1:
#					moveAirGroundTransition.erase(Globals.CharacterAnimations.UPSPECIAL)
#					moveGroundAirTransition.erase(Globals.CharacterAnimations.UPSPECIAL)
#		Globals.CharacterAnimations.NSPECIAL:
#			match neutralSpecialAnimationStep:
#				0:
#					moveAirGroundTransition[Globals.CharacterAnimations.NSPECIAL] = 1
#					moveGroundAirTransition[Globals.CharacterAnimations.NSPECIAL] = 1
#				2:
#					moveAirGroundTransition.erase(Globals.CharacterAnimations.NSPECIAL)
#					moveGroundAirTransition.erase(Globals.CharacterAnimations.NSPECIAL)
#		Globals.CharacterAnimations.DOWNSPECIAL:
#			match downSpecialAnimationStep:
#				0:
#					moveAirGroundTransition[Globals.CharacterAnimations.DOWNSPECIAL] = 1
#					moveGroundAirTransition[Globals.CharacterAnimations.DOWNSPECIAL] = 1
#				2:
#					moveAirGroundTransition.erase(Globals.CharacterAnimations.DOWNSPECIAL)
#					moveGroundAirTransition.erase(Globals.CharacterAnimations.DOWNSPECIAL)
#		Globals.CharacterAnimations.SIDESPECIAL:
#			match sideSpecialAnimationStep:
#				0:
#					moveAirGroundTransition[Globals.CharacterAnimations.SIDESPECIAL] = 1
#					moveGroundAirTransition[Globals.CharacterAnimations.SIDESPECIAL] = 1
#				1:
#					moveAirGroundTransition.erase(Globals.CharacterAnimations.SIDESPECIAL)
#					moveGroundAirTransition.erase(Globals.CharacterAnimations.SIDESPECIAL)

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
