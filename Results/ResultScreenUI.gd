extends HBoxContainer

onready var characterResultGUI = preload("res://Results/CharacterResult.tscn")
var characters = []
var charactersReady = []

func add_character_result_gui(character):
	characters.append(character)
	var newCharacterGUI = characterResultGUI.instance()
	newCharacterGUI.setup(character)
	add_child(newCharacterGUI)

func enable_result_gui():
	for gui in get_children():
		gui.enableInput = true

func ready_next_battle(character):
	charactersReady.append(character)
	if characters.size() == charactersReady.size():
		print("RESULTS DONE")
		
func not_ready_next_battle(character):
	charactersReady.erase(character)
