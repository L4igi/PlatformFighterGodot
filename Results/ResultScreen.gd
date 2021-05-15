extends Node2D


onready var animationPlayer = get_node("AnimationPlayer")

var winningCharacter = null
var losingCharacters = []
var allCharacters = []

var disableInput = true

onready var resultGUINode = get_node("ResultGUINode")
onready var resultGUIUI = get_node("ResultGUINode/ResultScreenUI")

# Called when the node enters the scene tree for the first time.
func _ready():
	Engine.set_time_scale(1.0)
	manage_character_ranking()
	
func _process(delta):
	if !disableInput:
		for character in allCharacters:
			if Input.is_action_just_pressed(character.attack):
				animationPlayer.play("slide_in_gui")
				disableInput = true
				yield(animationPlayer, "animation_finished")
				resultGUIUI.enable_result_gui()

func manage_character_ranking():
	var countCharacters = 0
	for character in Globals.characterRanking:
		if countCharacters == 0: 
			winningCharacter = character
			manage_winning_character(character)
		else:
			losingCharacters.append(character)
			manage_losing_characters(0, character,countCharacters)
		allCharacters.append(character)
		resultGUIUI.add_character_result_gui(character)
		character.change_state(Globals.CharacterState.GAMEOVER)
		countCharacters += 1
	Globals.characterRanking.clear()
	

func manage_winning_character(character):
	get_node("WinnerPosition").add_child(character)
	character.global_position = get_node("WinnerPosition").global_position
	character.state.play_animation("victory")
	character.animatedSprite.set_z_index(-10)
	yield(character.animationPlayer, "animation_finished")
	animationPlayer.play("slide_in_overlay")
	yield(animationPlayer, "animation_finished")
	for losingCharacter in losingCharacters:
		manage_losing_characters(1, losingCharacter)
	disableInput = false
	
func manage_losing_characters(step, character, count = 0):
	match step:
		0:
			var loserPosition = null
			match count: 
				1:
					loserPosition = get_node("Triangle/LoserPosition1")
				2:
					loserPosition = get_node("Triangle/LoserPosition2")
				3:
					loserPosition = get_node("Triangle/LoserPosition3")
			loserPosition.add_child(character)
			character.global_position = loserPosition.global_position
			loserPosition.set_visible(true)
			character.animationPlayer.get_parent().set_animation("lose")
			character.animationPlayer.get_parent().set_frame(0)
			character.animatedSprite.set_z_index(1)
		1:
			character.state.play_animation("lose")
			character.state.play_animation("loseloop", true)
	
