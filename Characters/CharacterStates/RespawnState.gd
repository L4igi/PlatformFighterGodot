extends State

class_name RespawnState

onready var revivalPlatform = preload("res://RevivalPlatform/RevivalPlatform.tscn")
var tempRevivalPlatform = null

var respawnTimer = null
var respawnFrames = 50.0
var respawnInvincibilityFrames = 300.0
var respawnPlatformTimer = null
var respawnPlatformFrames = 100.0

func _ready():
	create_respawn_timer(respawnFrames)
	create_invincibility_timer(respawnInvincibilityFrames)
	tempRevivalPlatform = revivalPlatform.instance()
	character.add_child(tempRevivalPlatform)
	tempRevivalPlatform.position.y += character.get_character_size().y/3
	character.bufferInvincibilityFrames = 120.0
	
func setup(change_state, transitionBufferedInput, animationPlayer, character):
	.setup(change_state, transitionBufferedInput, animationPlayer, character)
	character.reset_all()
	character.global_position = GlobalVariables.centerStage.respawnPositions[GlobalVariables.respawningCharacters.find(character)]
	respawnTimer = GlobalVariables.create_timer("on_respawn_timeout", "RespawnTimer", self)
	respawnPlatformTimer = GlobalVariables.create_timer("on_respawnPlatform_timeout", "RespawnPlatformTimer", self)
	character.disableInput = true
	GlobalVariables.respawningCharacters.append(character)
	
func handle_input(_delta): 
	if Input.is_action_just_pressed(character.down):
		tempRevivalPlatform.queue_free()
		character.change_state(GlobalVariables.CharacterState.AIR)
	elif Input.is_action_just_pressed(character.jump):
		tempRevivalPlatform.queue_free()
		character.change_state(GlobalVariables.CharacterState.AIR)
		double_jump_handler()
	elif Input.is_action_just_pressed(character.attack):
		tempRevivalPlatform.queue_free()
		character.change_state(GlobalVariables.CharacterState.ATTACKAIR)
	elif Input.is_action_just_pressed(character.special):
		tempRevivalPlatform.queue_free()
		character.change_state(character.change_to_special_state())
	elif Input.is_action_just_pressed(character.grab):
		tempRevivalPlatform.queue_free()
		character.change_state(GlobalVariables.CharacterState.AIRDODGE)
	elif Input.is_action_just_pressed(character.left):
		tempRevivalPlatform.queue_free()
		character.change_state(GlobalVariables.CharacterState.AIR)
	elif Input.is_action_just_pressed(character.right):
		tempRevivalPlatform.queue_free()
		character.change_state(GlobalVariables.CharacterState.AIR)
		
func _physics_process(_delta):
	if !stateDone: 
		if !character.disableInput:
			handle_input(_delta)
	
func create_respawn_timer(waitTimer):
	GlobalVariables.start_timer(respawnTimer, waitTimer)
	
func on_respawn_timeout():
	character.tween.interpolate_property(character, "global_position", character.global_position, character.global_position + Vector2(0,1000) , invincibilityTimer.get_time_left()/2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	character.tween.start()
	play_animation("idle")
	yield(character.tween, "tween_all_completed")
	character.disableInput = false
	create_respawn_platform_timer(respawnPlatformFrames)

func create_respawn_platform_timer(waitTime):
	GlobalVariables.start_timer(respawnPlatformTimer, waitTime)
	
func on_respawnPlatform_timeout():
	tempRevivalPlatform.queue_free()
	character.change_state(GlobalVariables.CharacterState.AIR)
