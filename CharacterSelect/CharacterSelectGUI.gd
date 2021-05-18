extends VBoxContainer

onready var characterButton = preload("res://CharacterSelect/CharacterButton.tscn")
onready var characterContainer = preload("res://CharacterSelect/CharacterContainer.tscn")
onready var characterGridContainer = get_node("CharacterSelectContainer/HBoxContainer/GridContainer")

# Called when the node enters the scene tree for the first time.
func _ready():
	for character in Globals.availableCharacters.keys():
		var newCharacterButton = characterButton.instance()
		newCharacterButton.setup(character)
		characterGridContainer.add_child(newCharacterButton)


func instance_character_container(playerName, playerNumber, uiNode):
	var newCharacterContainer = characterContainer.instance()
	newCharacterContainer.call_deferred("setup",playerName, playerNumber, uiNode)
	get_node("SelectedCharacterContainer/HBoxContainer").add_child(newCharacterContainer)
	for child in get_node("SelectedCharacterContainer/HBoxContainer").get_children():
		child.call_deferred("update_positions")
	return newCharacterContainer
