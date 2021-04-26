extends KinematicBody2D

class_name Projectile

var currentHitBox = 1
var currentState = null
var currentAttack = null
var currentMoveDirection = null
var grabAble = false
var damage = 0.0
var velocity = Vector2.ZERO
var bounce = false
var gravity = 0.0
#state changer 
var state_factory = null
var state = null
var stateChangedThisFrame = false
#animations 
onready var animatedSprite = get_node("AnimatedSprite")
onready var animationPlayer = get_node("AnimatedSprite/AnimationPlayer")
#json data
var projectileData = null
var attackDataEnum
#buffers 
var bufferedAnimation = null

func _ready():
	var file = File.new()
	file.open("res://Characters/Mario/marioAttacks.json", file.READ)
	var jsondata = JSON.parse(file.get_as_text())
	file.close()
	projectileData = jsondata.get_result()
	attackDataEnum = GlobalVariables.ProjectileAnimations
	animationPlayer.set_animation_process_mode(0)
	state_factory = ProjectileStateFactory.new()
	change_state(GlobalVariables.ProjectileState.SHOOT)

func change_state(new_state):
	if currentState == new_state:
		state.switch_to_current_state_again()
		return
	if stateChangedThisFrame:
		print(str(GlobalVariables.ProjectileState.keys()[new_state]) +" State already changed this frame ")
		return
	stateChangedThisFrame = true
	var changeToState = new_state
#	check_character_tilt_walk(new_state)
	if state != null:
		state.stateDone = true
#		changeToState = check_state_transition(changeToState)
#		bufferedAnimation = state.bufferedAnimation
		state.queue_free()
#		if state.is_queued_for_deletion():
#			print(str(state.name) +" STATE CAN BE QUEUED FREE AFTER FRAME")
#		else:
#			print(str(state.name) +"STATE CANNOT BE QUEUED FREE AFTER FRAME")
	print(self.name + " Changing to " +str(GlobalVariables.ProjectileState.keys()[changeToState]))
	state = state_factory.get_state(changeToState).new()
	state.name = GlobalVariables.ProjectileState.keys()[new_state]
#	if state.get_parent():
#		print("currentstate " +str(currentState) + " new state " +str(new_state))
#		print("state " +str(GlobalVariables.CharacterState.keys()[changeToState]) + " already has parent " +str(state.get_parent()))
	state.setup(funcref(self, "change_state"),animationPlayer, self)
	currentState = changeToState
	add_child(state)

