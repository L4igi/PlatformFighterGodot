extends MarginContainer

class_name CharacterContainer

onready var characterIcon = get_node("HBoxContainer/MarginContainer/CharacterIcon")
onready var characterLogo = get_node("HBoxContainer/MarginContainer2/VBoxContainer2/CharacterLogo")
onready var charactername = get_node("HBoxContainer/MarginContainer2/VBoxContainer/MarginContainer/CharacterName")
onready var playerName = get_node("HBoxContainer/MarginContainer2/VBoxContainer/MarginContainer2/PlayerName")
onready var playerNumber = get_node("HBoxContainer/MarginContainer2/VBoxContainer/MarginContainer3/PlayerNumber")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func setup(playerName, playerNumber):
	set_player_name(playerName)
	set_player_number(playerNumber)
	
func setup_hover(characterIcon, characterLogo, characterName):
	set_icon(characterIcon)
	set_logo(characterLogo)
	set_character_name(characterName)
	
func remove_hover():
	set_icon(null)
	set_logo(null)
	set_character_name("")
	
func set_icon(characterIcon):
	self.characterIcon.set_texture(characterIcon)
	
func set_logo(characterLogo):
	self.characterLogo.set_texture(characterLogo)
	
func set_character_name(characterName):
	self.charactername.set_bbcode("[center]"+str(characterName)+"[/center]")
	
func set_player_name(playerName):
	self.playerName.set_bbcode("[center]"+str(playerName)+"[/center]")
	
func set_player_number(playerNumber):
	self.playerNumber.set_bbcode("[center]"+str(playerNumber)+"[/center]")
