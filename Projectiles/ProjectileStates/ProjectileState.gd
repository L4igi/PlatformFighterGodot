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
#state done 
var stateDone = false

func _ready():
	pass
	
func setup(change_state, animationPlayer, projectile):
	self.change_state = change_state
	self.animationPlayer = animationPlayer
	self.projectile = projectile
	self.bufferedAnimation = projectile.bufferedAnimation
	hitlagTimer = GlobalVariables.create_timer("on_hitlag_timeout", "HitLagTimer", self)
	hitlagAttackedTimer = GlobalVariables.create_timer("on_hitlagAttacked_timeout", "HitLagTimer", self)

func switch_to_current_state_again():
	pass
	
func create_hitlag_timer(waitTime):
	if !hitlagTimer.get_time_left():
		projectile.projectileTTLTimer.set_paused(true)
	#	character.toggle_all_hitboxes("off")
		animationPlayer.stop(false)
		gravity_on_off("off")
		if projectile.initLaunchVelocity == null:
			projectile.initLaunchVelocity = projectile.velocity
		projectile.velocity = Vector2.ZERO
		projectile.backUpDisableInput = projectile.disableInput
		projectile.disableInput = true
	GlobalVariables.start_timer(hitlagTimer, waitTime)
	
func on_hitlag_timeout():
	projectile.projectileTTLTimer.set_paused(false)
	gravity_on_off("on")
	projectile.velocity = projectile.initLaunchVelocity
	projectile.initLaunchVelocity = null
	animationPlayer.play()
	projectile.on_impact()

func create_hitlagAttacked_timer(waitTime):
	projectile.projectileTTLTimer.set_paused(true)
	hitlagTimer.stop()
	gravity_on_off("off")
	if projectile.initLaunchVelocity == null:
		projectile.initLaunchVelocity = projectile.velocity
	animationPlayer.stop(false)
	projectile.disableInput = true
	projectile.velocity = Vector2.ZERO
	GlobalVariables.start_timer(hitlagAttackedTimer, waitTime)
	
func on_hitlagAttacked_timeout():
	projectile.projectileTTLTimer.set_paused(false)
	gravity_on_off("on")
	projectile.velocity = projectile.initLaunchVelocity
	projectile.initLaunchVelocity = null
	animationPlayer.play()
	projectile.on_impact()

func gravity_on_off(status):
	if status == "on":
		projectile.gravity = projectile.baseGravity
	elif status == "off":
		projectile.gravity = 0

func play_animation(animationToPlay, queue = false):
#	print("play " +str(animationToPlay) +str(queue))
	animationPlayer.playback_speed = 1
	reset_animatedSprite()
	if queue:
		animationPlayer.queue(animationToPlay)
	else:
		animationPlayer.play(animationToPlay)
		
func reset_animatedSprite():
	projectile.animatedSprite.set_rotation_degrees(0.0)
	projectile.animatedSprite.set_position(Vector2(0,0))
	projectile.animatedSprite.set_modulate(Color(1,1,1,1))
	projectile.animatedSprite.set_scale(Vector2(1,1))
