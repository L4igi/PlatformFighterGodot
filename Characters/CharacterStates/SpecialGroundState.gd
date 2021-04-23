extends State

class_name SpecialGround

func _ready():
	character.currentHitBox = 1

func setup(change_state, animationPlayer, character):
	.setup(change_state, animationPlayer, character)

func _physics_process(delta):
	mario()
func mario():
	print("in parent mario")
