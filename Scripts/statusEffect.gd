extends Node2D

@onready var progress_bar = $ProgressBar
# @onready var seconds_timer = $SecondsTimer
@onready var timer = $Timer

enum TYPE {ADD = 0, MULPIPLY = 1} 
var value: float = 0
var type: TYPE = TYPE.ADD

func start_timer(time):
	timer.wait_time = time
	progress_bar.max_value = timer.wait_time
	progress_bar.value = progress_bar.max_value	
	progress_bar.seconds_timer.start()
	timer.start()

func get_progress_bar():
	return progress_bar


func _on_timer_timeout():
	queue_free()
