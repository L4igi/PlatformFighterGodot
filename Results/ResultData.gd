extends Node

class_name ResultData

var characterName = ""
var playerNumber = 0
#var damageDealt = 0
#var maxDamageDealt = 0
#var damageReceived = 0
#var maxDamageReceived = 0
#var damageRecovered = 0
#var peakDamage = 0
#var stocksLeft = 0
#var launchDistance = 0
#var groundTime = 0
#var airTime = 0 
#var groundAttacksUsed = 0
#var airAttacksUsed = 0
#var smashAttacksUsed = 0
#var grabs = 0 
#var throws = 0
#var edgeGrabs = 0
#var projectiles = 0
#var itemsGrabbed = 0
#var maxLaunchSpeed = 0
#var maxLauncherSpeed = 0
#var kos = 0
#var falls = 0
#var sds = 0
#var characterOutAt = 0.0

var statDictionary = {}

func resultdata_setup(characterName, playerNumber, stocksLeft):
	self.characterName = characterName
	self.playerNumber = playerNumber
	statDictionary["stocksLeft"] = stocksLeft
	statDictionary["damageDealt"] = 0
	statDictionary["maxDamageDealt"] = 0
	statDictionary["damageReceived"] = 0
	statDictionary["maxDamageReceived"] = 0
	statDictionary["damageRecovered"] = 0
	statDictionary["peakDamage"] = 0
	statDictionary["launchDistance"] = 0
	statDictionary["groundTime"] = 0
	statDictionary["airTime"] = 0
	statDictionary["groundAttacksUsed"] = 0
	statDictionary["airAttacksUsed"] = 0
	statDictionary["smashAttacksUsed"] = 0
	statDictionary["grabs"] = 0
	statDictionary["throws"] = 0
	statDictionary["edgeGrabs"] = 0
	statDictionary["projectiles"] = 0
	statDictionary["itemsGrabbed"] = 0
	statDictionary["maxLaunchSpeed"] = 0
	statDictionary["maxLauncherSpeed"] = 0
	statDictionary["kos"] = 0
	statDictionary["falls"] = 0
	statDictionary["sds"] = 0
	statDictionary["characterOutAt"] = 0

func add_damage_received(damageReceived):
	if damageReceived > statDictionary.get("maxDamageReceived"):
		statDictionary["maxDamageReceived"] = damageReceived
	statDictionary["damageReceived"] = statDictionary.get("damageReceived") + damageReceived

func add_damage_taken(damageDealt):
	if damageDealt > statDictionary.get("maxDamageDealt"):
		statDictionary["maxDamageDealt"] = damageDealt
	statDictionary["damageDealt"] = statDictionary.get("damageDealt") + damageDealt

func remove_stock(currentPercent):
	if currentPercent > statDictionary.get("peakDamage"):
		statDictionary["peakDamage"] = currentPercent
	statDictionary["stocksLeft"] = statDictionary.get("stocksLeft") - 1
	
func on_character_defeat(time):
	statDictionary["characterOutAt"] = time
