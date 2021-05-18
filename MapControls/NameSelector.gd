extends ItemList


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var playerNameSelectedItem = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	add_item("Enter new Name")
	self.select(playerNameSelectedItem)

func check_who_pressed():
	for control in Globals.availableControls:
		if Input.is_action_just_pressed(control.get("attack")):
			var selectedName = self.get_item_text(playerNameSelectedItem)
			if selectedName == "Enter new Name":
				enter_new_name()
		if Input.is_action_just_pressed(control.get("down")):
			if playerNameSelectedItem < self.get_item_count()-1:
				playerNameSelectedItem += 1
				self.select(playerNameSelectedItem)
				self.ensure_current_is_visible()
		elif Input.is_action_just_pressed(control.get("up")):
			if playerNameSelectedItem > 0:
				playerNameSelectedItem -= 1
				self.select(playerNameSelectedItem)
				self.ensure_current_is_visible()

func _process(delta):
	check_who_pressed()

func enter_new_name():
	pass
