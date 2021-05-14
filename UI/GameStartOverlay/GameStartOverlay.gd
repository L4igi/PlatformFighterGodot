extends MarginContainer

onready var countDownLabel = get_node("CountDownLabel")
var countDown = 3
var gameStartTimer = null
var queueFreeTimer = null
# Called when the node enters the scene tree for the first time.
func _ready():
	countDownLabel.set_bbcode("[center]3[/center]")

func _process(_delta):
	if gameStartTimer:
		if ceil(gameStartTimer.get_time_left()) < countDown:
			countDown -= 1
			decrease_countDown()


func decrease_countDown():
	if countDown == 0: 
		countDownLabel.set_bbcode("[center]GO![/center]")
		gameStartTimer = GlobalVariables.create_timer("on_queueFree_timeout", "gameStartCountdownQueueFreeTimer", self)
		GlobalVariables.start_timer(gameStartTimer, 20)
	else: 
		countDownLabel.set_bbcode("[center]"+str(countDown)+"[/center]")

func on_queueFree_timeout():
	self.queue_free()
