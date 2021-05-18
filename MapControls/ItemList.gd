extends ItemList

var smallCharacter = "abcdefghijklmnopqrstuvwxyz"
var bigCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
var numbers = "0123456789"
var symbols = "?!"

var currentCharacters = smallCharacter

var currentControls = Globals.controlsP1

var selectedSymbol = 0

func handle_input():
	if Input.is_action_just_pressed(currentControls.get("attack")):
		var selectedName = self.get_item_text(selectedSymbol)
		print(str(selectedName))
	if Input.is_action_just_pressed(currentControls.get("down")):
		if selectedSymbol < self.get_item_count()-get_max_columns():
			selectedSymbol += get_max_columns()
		else:
			var overshoot = (selectedSymbol + get_max_columns())%get_max_columns()
			selectedSymbol = overshoot
		self.select(selectedSymbol)
		self.ensure_current_is_visible()
	elif Input.is_action_just_pressed(currentControls.get("up")):
		if selectedSymbol > 0:
			selectedSymbol -= get_max_columns()
		else:
			var undershoot = abs(get_item_count()-1 - selectedSymbol)
			selectedSymbol = undershoot
		self.select(selectedSymbol)
		self.ensure_current_is_visible()
	elif Input.is_action_just_pressed(currentControls.get("left")):
		if selectedSymbol > 0:
			selectedSymbol -= 1
		else:
			selectedSymbol = get_item_count()-1
		self.select(selectedSymbol)
		self.ensure_current_is_visible()
	elif Input.is_action_just_pressed(currentControls.get("right")):
		if selectedSymbol < get_item_count()-1:
			selectedSymbol += 1
		else:
			selectedSymbol = 0
		self.select(selectedSymbol)
		self.ensure_current_is_visible()
# Called when the node enters the scene tree for the first time.
func _ready():
	setup_keyboard()
	self.select(selectedSymbol)
	
func _process(delta):
	handle_input()

func setup_keyboard():
	for symbol in smallCharacter: 
		add_item(str(symbol))
	add_item(str("-<"))
	add_item(str("()"))
