extends HBoxContainer

onready var characterResultGUI = preload("res://Results/CharacterResult.tscn")
var characters = []
var charactersReady = []

func add_character_result_gui(character):
	characters.append(character)
	var newCharacterGUI = characterResultGUI.instance()
	add_child(newCharacterGUI)
	newCharacterGUI.call_deferred("setup",character)

func enable_result_gui():
	for gui in get_children():
		gui.enableInput = true

func ready_next_battle(character):
	charactersReady.append(character)
	if characters.size() == charactersReady.size():
		Globals.switch_to_character_select()
		
func not_ready_next_battle(character):
	charactersReady.erase(character)
