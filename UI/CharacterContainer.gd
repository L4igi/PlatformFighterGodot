extends MarginContainer

onready var characterPortrait = get_node("VBoxContainer/HBoxContainer/MarginContainer/CharacterPortrait")
onready var characterNameLabel = get_node("VBoxContainer/HBoxContainer/VBoxContainer/CharacterName/CharacterNameLabel")
onready var characterNameBg = get_node("VBoxContainer/HBoxContainer/VBoxContainer/CharacterName/CharacterNameBg")
onready var stocksContainer = get_node("VBoxContainer/StocksContainer/HBoxContainer")
onready var damagePercentLabel = get_node("VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer/DamagePercent")

onready var stocksTextureRect = preload("res://UI/StocksTextureRect.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func set_label_name(charName):
	characterNameLabel.set_text(charName)
	
func set_character_portrait(portraittexture):
	characterPortrait.set_texture(portraittexture)
	
func set_damage_percent(damagePercent):
	damagePercentLabel.set_text(str(damagePercent) + "%")
	
func set_stocks(stocks):
	for i in stocks:
		var newStock = stocksTextureRect.instance()
		stocksContainer.add_child(newStock)
	
func remove_stock():
	var allStocks = stocksContainer.get_children()
	allStocks.back().queue_free()
