extends Node

class_name ResultData

var characterName = ""
var playerNumber = 0
var damageDealt = 0
var maxDamageDealt = 0
var damageReceived = 0
var maxDamageReceived = 0
var stocksLeft = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func resultdata_setup(characterName, playerNumber, stocksLeft):
	self.characterName = characterName
	self.playerNumber = playerNumber
	self.stocksLeft = stocksLeft

func add_damage_received(damageReceived):
	if damageReceived > maxDamageReceived:
		maxDamageReceived = damageReceived
	self.damageReceived += damageReceived

func add_damage_taken(damageDealt):
	if damageDealt > maxDamageDealt: 
		maxDamageDealt = damageDealt
	self.damageDealt += damageDealt
