extends MarginContainer

onready var characterPortrait = get_node("VBoxContainer/HBoxContainer/CharacterPortrait")
onready var characterNameLabel = get_node("VBoxContainer/HBoxContainer/VBoxContainer/CharacterName/CharacterNameLabel")
onready var characterNameBg = get_node("VBoxContainer/HBoxContainer/VBoxContainer/CharacterName/CharacterNameBg")
onready var stocksFilles = get_node("VBoxContainer/StocksContainer/StocksFilled")
onready var stocksEmpty = get_node("VBoxContainer/StocksContainer/stocksEmpty")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_label_name(charName):
	pass
	
func set_character_portrait(portraittexture):
	pass
	
func set_damage_percent(damagePercent):
	pass
	
func set_stocks(stocks):
	pass
	
