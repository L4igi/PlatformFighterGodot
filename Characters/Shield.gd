extends Node2D

onready var shieldSprite = $ShieldSprite
var shieldHealth = 50.0
var baseShieldHealth = 50.0
var shieldBreakHealth = 37.5
var shieldEnabled = false
var shieldBreak = false
var character 
var pauseShield = false
# Called when the node enters the scene tree for the first time.
func _ready():
	character = get_parent()
	set_visible(false)
	
	
func _physics_process(delta):
	if shieldHealth <= 0 && !shieldBreak: 
		shieldHealth = 0
		shieldBreak = true
		print("SHIELDBREAK!!!")
		var shieldScale = shieldHealth/baseShieldHealth
		shieldSprite.set_scale(Vector2(shieldScale, shieldScale))
	if !pauseShield && !shieldBreak:
		if shieldEnabled && shieldHealth > 0\
		&& !character.hitLagTimer.timer_running(): 
			shieldHealth -= 0.15
			var shieldScale = shieldHealth/baseShieldHealth
			shieldSprite.set_scale(Vector2(shieldScale, shieldScale))
		elif !shieldEnabled && shieldHealth < baseShieldHealth:
			shieldHealth += 0.08
	#		print(shieldHealth)
			var shieldScale = shieldHealth/baseShieldHealth
			shieldSprite.set_scale(Vector2(shieldScale, shieldScale))

func enable_shield():
	set_visible(true)
	shieldEnabled = true
	
	
func disable_shield():
	set_visible(false)
	shieldEnabled = false
	
func pause_shield():
	pauseShield = true

func unpause_shield():
	pauseShield = false

func apply_shield_damage(damage, shieldDamage):
	shieldHealth -= (damage + shieldDamage) * 1.19
