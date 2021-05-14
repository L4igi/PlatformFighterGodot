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
	moveAirGroundTransition[GlobalVariables.CharacterAnimations.DAIR] = 1
	set_base_stats()
	#set state factory according to character
	state_factory = MarioStateFactory.new()
#	if !onSolidGround:
#		change_state(GlobalVariables.CharacterState.AIR)
	change_state(GlobalVariables.CharacterState.GAMESTART)
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
		GlobalVariables.CharacterAnimations.DAIR: 
			manage_dair(step)
		GlobalVariables.CharacterAnimations.DASHATTACK:
			manage_dash_attack(step)
			
func apply_special_animation_steps(step = 0):
	match currentAttack:
		GlobalVariables.CharacterAnimations.UPSPECIAL:
			manage_up_special(step)
		GlobalVariables.CharacterAnimations.DOWNSPECIAL:
			manage_down_special(step)
		GlobalVariables.CharacterAnimations.SIDESPECIAL:
			manage_side_special(step)
		GlobalVariables.CharacterAnimations.NSPECIAL:
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
				GlobalVariables.MoveDirection.LEFT:
					velocity = Vector2(-upSpecialSpeed.x, -upSpecialSpeed.y)
				GlobalVariables.MoveDirection.RIGHT:
					velocity = Vector2(upSpecialSpeed.x, -upSpecialSpeed.y)
			
func manage_neutral_special(step = 0):
	neutralSpecialAnimationStep = step
	match step:
		0:
			enableSpecialInput = false
		1:
			var newFireBall = fireBall.instance()
#			newFireBall.set_base_stats(self, self)
			GlobalVariables.currentStage.call_deferred("add_child" ,newFireBall)
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
					chargingProjectile.change_state(GlobalVariables.ProjectileState.CHARGE)
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
			changeToState = GlobalVariables.CharacterState.ATTACKGROUND
		else:
			changeToState = GlobalVariables.CharacterState.SPECIALGROUND
	else:
		if grabbedItem && get_input_direction_x() == 0 && get_input_direction_y() == 0:
			changeToState = GlobalVariables.CharacterState.ATTACKAIR
		else:
			changeToState = GlobalVariables.CharacterState.SPECIALAIR
	return changeToState

#func check_special_animation_steps():
#	match currentAttack:
#		GlobalVariables.CharacterAnimations.UPSPECIAL:
#			match upSpecialAnimationStep:
#				0:
#					moveAirGroundTransition[GlobalVariables.CharacterAnimations.UPSPECIAL] = 1
#					moveGroundAirTransition[GlobalVariables.CharacterAnimations.UPSPECIAL] = 1
#				1:
#					moveAirGroundTransition.erase(GlobalVariables.CharacterAnimations.UPSPECIAL)
#					moveGroundAirTransition.erase(GlobalVariables.CharacterAnimations.UPSPECIAL)
#		GlobalVariables.CharacterAnimations.NSPECIAL:
#			match neutralSpecialAnimationStep:
#				0:
#					moveAirGroundTransition[GlobalVariables.CharacterAnimations.NSPECIAL] = 1
#					moveGroundAirTransition[GlobalVariables.CharacterAnimations.NSPECIAL] = 1
#				2:
#					moveAirGroundTransition.erase(GlobalVariables.CharacterAnimations.NSPECIAL)
#					moveGroundAirTransition.erase(GlobalVariables.CharacterAnimations.NSPECIAL)
#		GlobalVariables.CharacterAnimations.DOWNSPECIAL:
#			match downSpecialAnimationStep:
#				0:
#					moveAirGroundTransition[GlobalVariables.CharacterAnimations.DOWNSPECIAL] = 1
#					moveGroundAirTransition[GlobalVariables.CharacterAnimations.DOWNSPECIAL] = 1
#				2:
#					moveAirGroundTransition.erase(GlobalVariables.CharacterAnimations.DOWNSPECIAL)
#					moveGroundAirTransition.erase(GlobalVariables.CharacterAnimations.DOWNSPECIAL)
#		GlobalVariables.CharacterAnimations.SIDESPECIAL:
#			match sideSpecialAnimationStep:
#				0:
#					moveAirGroundTransition[GlobalVariables.CharacterAnimations.SIDESPECIAL] = 1
#					moveGroundAirTransition[GlobalVariables.CharacterAnimations.SIDESPECIAL] = 1
#				1:
#					moveAirGroundTransition.erase(GlobalVariables.CharacterAnimations.SIDESPECIAL)
#					moveGroundAirTransition.erase(GlobalVariables.CharacterAnimations.SIDESPECIAL)

func initialize_special_animation_steps():
	match currentAttack:
		GlobalVariables.CharacterAnimations.UPSPECIAL:
			moveAirGroundTransition[GlobalVariables.CharacterAnimations.UPSPECIAL] = 1
			moveGroundAirTransition[GlobalVariables.CharacterAnimations.UPSPECIAL] = 1
		GlobalVariables.CharacterAnimations.NSPECIAL:
			moveAirGroundTransition[GlobalVariables.CharacterAnimations.NSPECIAL] = 1
			moveGroundAirTransition[GlobalVariables.CharacterAnimations.NSPECIAL] = 1
		GlobalVariables.CharacterAnimations.DOWNSPECIAL:
			moveAirGroundTransition[GlobalVariables.CharacterAnimations.DOWNSPECIAL] = 1
			moveGroundAirTransition[GlobalVariables.CharacterAnimations.DOWNSPECIAL] = 1
		GlobalVariables.CharacterAnimations.SIDESPECIAL:
			moveAirGroundTransition[GlobalVariables.CharacterAnimations.SIDESPECIAL] = 1
			moveGroundAirTransition[GlobalVariables.CharacterAnimations.SIDESPECIAL] = 1

func finish_special_animation(step):
	match currentAttack:
		GlobalVariables.CharacterAnimations.UPSPECIAL:
			moveAirGroundTransition.erase(GlobalVariables.CharacterAnimations.UPSPECIAL)
			moveGroundAirTransition.erase(GlobalVariables.CharacterAnimations.UPSPECIAL)
			change_state(GlobalVariables.CharacterState.HELPLESS)
			return
		GlobalVariables.CharacterAnimations.NSPECIAL:
			moveAirGroundTransition.erase(GlobalVariables.CharacterAnimations.NSPECIAL)
			moveGroundAirTransition.erase(GlobalVariables.CharacterAnimations.NSPECIAL)
		GlobalVariables.CharacterAnimations.DOWNSPECIAL:
			moveAirGroundTransition.erase(GlobalVariables.CharacterAnimations.DOWNSPECIAL)
			moveGroundAirTransition.erase(GlobalVariables.CharacterAnimations.DOWNSPECIAL)
		GlobalVariables.CharacterAnimations.SIDESPECIAL:
			moveAirGroundTransition.erase(GlobalVariables.CharacterAnimations.SIDESPECIAL)
			moveGroundAirTransition.erase(GlobalVariables.CharacterAnimations.SIDESPECIAL)
	.finish_special_animation(step)


func manage_throw_item_special_moves():
	currentAttack = GlobalVariables.CharacterAnimations.THROWITEMFORWARD
	state.play_attack_animation("throw_item_forward")
