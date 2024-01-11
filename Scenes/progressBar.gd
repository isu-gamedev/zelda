extends TextureProgressBar

@onready var seconds_timer = $SecondsTimer
@onready var timer = $Timer

func _ready():
	timer.wait_time = max_value
	timer.start()
	seconds_timer.start()
	
func _on_seconds_timer_timeout():
	value -= step

func _on_timer_timeout():
	queue_free()
