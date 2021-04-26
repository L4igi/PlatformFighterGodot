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
