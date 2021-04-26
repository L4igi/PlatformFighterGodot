extends Node2D

class_name ProjectileState

var change_state = null
var animationPlayer = null
var projectile = null
#projectile timers
var hitlagTimer = null
var hitlagAttackedTimer = null
#buffer animations 
var bufferedAnimation = null

func _ready():
	hitlagTimer = create_timer("on_hitlag_timeout", "HitLagTimer")
	hitlagAttackedTimer = create_timer("on_hitlag_timeout", "HitLagTimer")
	
func setup(change_state, animationPlayer, projectile):
	self.change_state = change_state
	self.animationPlayer = animationPlayer
	self.projectile = projectile
	self.bufferedAnimation = projectile.bufferedAnimation

func switch_to_current_state_again():
	pass

func create_timer(timeout_function, timerName):
	var timer = Timer.new()    
	timer.set_name(timerName)
	add_child (timer)
	timer.connect("timeout", self, timeout_function) 
	return timer
	
func start_timer(timer, waitTime, oneShot = true):
	timer.set_wait_time(waitTime/60.0)
	timer.set_one_shot(oneShot)
	timer.start()
	
func create_hitlag_timer(waitTime):
	if !hitlagTimer.get_time_left():
	#	character.toggle_all_hitboxes("off")
		animationPlayer.stop(false)
		gravity_on_off("off")
		projectile.velocity = Vector2.ZERO
		projectile.backUpDisableInput = projectile.disableInput
		projectile.disableInput = true
	start_timer(hitlagTimer, waitTime)
	
func on_hitlag_timeout():
	#character.toggle_all_hitboxes("on")
	gravity_on_off("on")
	projectile.velocity = projectile.initLaunchVelocity
	animationPlayer.play()

func create_hitlagAttacked_timer(waitTime):
	hitlagTimer.stop()
	gravity_on_off("off")
	animationPlayer.stop(false)
	projectile.disableInput = true
	projectile.velocity = Vector2.ZERO
	start_timer(hitlagAttackedTimer, waitTime)
	
func on_hitlagAttacked_timeout():
	gravity_on_off("on")
	animationPlayer.play()

func gravity_on_off(status):
	if status == "on":
		projectile.gravity = projectile.baseGravity
	elif status == "off":
		projectile.gravity = 0

