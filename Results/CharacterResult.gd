extends MarginContainer

var character = null
var currentStep = 0
var enableInput = false

func setup(character):
	self.character = character
	
func set_current_step_zero():
	currentStep = 0
	
func _process(delta):
	if Input.is_action_just_pressed(character.attack):
		advance_menu(currentStep)
		currentStep += 1

func advance_menu(step = 0):
	match step: 
		0: 
			get_node("CharacterInfo").move_child(get_node("CharacterInfo/CharPlayerInfo"),0)
			get_node("BaseResults").set_visible(true)
		1:
			get_node("BaseResults").set_visible(false)
			get_node("ExtendedResults").set_visible(true)
		2:
			pass
