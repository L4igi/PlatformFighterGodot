extends Node2D

onready var shieldSprite = $ShieldSprite
var shieldHealth = 50.0
var baseShieldHealth = 50.0
var shieldBreakHealth = 37.5
var shieldEnabled = false
var shieldBreak = false
var character 
var pauseShield = false
var enableShieldFrames = 3
var bufferShieldDamage = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	character = get_parent()
	set_visible(false)
	
func setup(change_state, animationPlayer, character):
	.setup(change_state, animationPlayer, character)
	character.jumpCount = 0
	
func _physics_process(_delta):
	if enableShieldFrames > 0: 
		enableShieldFrames -= 1
	if shieldHealth <= 0 && !shieldBreak: 
		apply_shield_break()
	if !pauseShield && !shieldBreak:
		if shieldEnabled && shieldHealth > 0: 
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
	enableShieldFrames = 3
	
func disable_shield():
	set_visible(false)
	shieldEnabled = false
	
func pause_shield():
	pauseShield = true

func unpause_shield():
	pauseShield = false

func apply_shield_damage():
	shieldHealth -= bufferShieldDamage
	bufferShieldDamage = 0
	
func buffer_shield_damage(damage, shieldDamage):
	bufferShieldDamage = (damage + shieldDamage) * 1.19
	
func apply_shield_break():
	shieldHealth = 0
	shieldBreak = true
	character.change_state(GlobalVariables.CharacterState.SHIELDBREAK)
	var shieldScale = shieldHealth/baseShieldHealth
	shieldSprite.set_scale(Vector2(shieldScale, shieldScale))
	
func shieldBreak_end():
	shieldBreak = false
	shieldHealth = shieldBreakHealth
