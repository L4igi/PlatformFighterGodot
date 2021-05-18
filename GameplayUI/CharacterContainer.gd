extends MarginContainer

onready var characterIcon = get_node("VBoxContainer/HBoxContainer/MarginContainer/CharacterIcon")
onready var characterLogo = get_node("VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer/MarginContainer/HBoxContainer/CharacterLogo")
onready var characterNameLabel = get_node("VBoxContainer/HBoxContainer/VBoxContainer/CharacterName/CharacterNameLabel")
onready var characterNameBg = get_node("VBoxContainer/HBoxContainer/VBoxContainer/CharacterName/CharacterNameBg")
onready var stocksContainer = get_node("VBoxContainer/StocksContainer")
onready var damagePercentLabel = get_node("VBoxContainer/HBoxContainer/VBoxContainer/MarginContainer/DamagePercent")

onready var stocksTextureRect = preload("res://GameplayUI/StocksTextureRect.tscn")

var character = null

# Called when the node enters the scene tree for the first time.
func _ready():
	set_label_name(character.characterName)
	set_character_icon(character.characterIcon, character.characterColor)
	set_character_logo(character.characterLogo)
	set_damage_percent(0.0)
	set_stocks(character.stocks)

func setup(character):
	self.character = character

func set_label_name(charName):
	characterNameLabel.set_bbcode("[center]"+charName+"[/center]")
	
func set_character_icon(iconTexture, color):
	characterIcon.set_texture(iconTexture)
	characterIcon.set_modulate(color)
	
func set_character_logo(logoTexture):
	characterLogo.set_texture(logoTexture)
	
func set_damage_percent(damagePercent):
	damagePercentLabel.set_bbcode("[center]"+str(damagePercent)+"%"+"[/center]")
	
func set_stocks(stocks):
	for i in stocks:
		var newStock = stocksTextureRect.instance()
		stocksContainer.add_child(newStock)
	
func remove_stock():
	var allStocks = stocksContainer.get_children()
	allStocks.back().queue_free()
