extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
 
@onready var hp_bar = $CanvasLayer/MarginContainer/HP
@onready var hp_item = $CanvasLayer/MarginContainer/HP/TextureRect
@onready var coins_number = $CanvasLayer/CoinsNumber
@onready var status_container = $CanvasLayer/StatusContainer

func add_hp(num):
	for i in range(num):
		var h = hp_item.duplicate()
		hp_bar.add_child(h)

func remove_hp(num):
	for i in range(num):
		hp_bar.remove_child(hp_bar.get_child(hp_bar.get_child_count() - 1))
	
func _on_player_health_changed(diff):
	# var diff = old_hp - new_hp
	if diff > 0:
		add_hp(diff)
	else: remove_hp(-diff)


func _on_player_tree_exited():
	remove_hp(hp_bar.get_child_count())
	
func change_coins(new_value):
	coins_number.text = str(new_value)

func _on_player_amplifier_added(amplifier):
	print("where")
	status_container.add_child(amplifier.get_progress_bar().duplicate())
	# print(amplifier.get_progress_bar().duplicate())
