extends Node

@onready var timer = $IframesTimer 

@export var maxHp: int
@export var currHp: int = -1
@export var iframes: float = 0


signal char_dead
signal damage_taken(damage)
signal healed(hp)

func _ready():
	if currHp == -1:
		currHp = maxHp
	timer.wait_time = iframes
	
func heal(delta):
	if currHp <= 0:
		return
	if delta + currHp > maxHp:
		delta = maxHp - currHp
		currHp = maxHp
	else:
		currHp += delta
	healed.emit(delta)

func damage(delta):
	if currHp <= 0:
		return
	if iframes != 0 and timer.time_left > 0:
		return
	currHp -= delta
	damage_taken.emit(delta)
	timer.start()
	if currHp <= 0:
		char_dead.emit()
