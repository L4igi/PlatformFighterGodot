extends Node

var activeTimers = []

func _init(character):
	character.add_child(self)

func _physics_process(delta):
	if !activeTimers.empty():
		var timersDone = []
		for frameTimer in activeTimers:
			if frameTimer.timerStarted && frameTimer.frames > 0 && !frameTimer.pausedTimer: 
				frameTimer.frames -= 1
			elif frameTimer.frames == 0 && frameTimer.timerStarted: 
				frameTimer.timerStarted = false
				frameTimer.emit_signal("timeout", frameTimer.timerType)
				timersDone.append(frameTimer)
			elif frameTimer.pausedTimer && frameTimer.pauseDuration > 0: 
				frameTimer.pauseDuration -= 1
				if frameTimer.pauseDuration == 0: 
					frameTimer.pausedTimer = false
		if !timersDone.empty():
			for frameTimer in timersDone:
				remove_timer(frameTimer)

func add_timer(frameTimer):
	if !activeTimers.has(frameTimer):
#		print("adding " +str(frameTimer))
		activeTimers.append(frameTimer)
	
func remove_timer(frameTimer):
	if activeTimers.has(frameTimer):
#		print("removing " +str(frameTimer))
		activeTimers.erase(frameTimer)
