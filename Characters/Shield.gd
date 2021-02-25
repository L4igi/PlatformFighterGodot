extends Node2D

onready var shieldSprite = $ShieldSprite
var shieldHealth = 1000.0
var baseShieldHealth = 1000.0
var shieldEnabled = false
var shieldBreak = false
var character 
# Called when the node enters the scene tree for the first time.
func _ready():
	character = get_parent()
	set_visible(false)
	
	
func _physics_process(delta):
	if shieldHealth == 0 && !shieldBreak: 
		shieldBreak = true
		print("SHIELDBREAK!!!")
	elif shieldEnabled && shieldHealth > 0\
	&& !character.hitLagTimer.timer_running(): 
		shieldHealth-=1
		var shieldScale = shieldHealth/baseShieldHealth
		shieldSprite.set_scale(Vector2(shieldScale, shieldScale))
	elif !shieldEnabled && shieldHealth < baseShieldHealth:
		shieldHealth+=1
#		print(shieldHealth)
		var shieldScale = shieldHealth/baseShieldHealth
		shieldSprite.set_scale(Vector2(shieldScale, shieldScale))

func enable_shield():
	set_visible(true)
	shieldEnabled = true
	
	
func disable_shield():
	set_visible(false)
	shieldEnabled = false
