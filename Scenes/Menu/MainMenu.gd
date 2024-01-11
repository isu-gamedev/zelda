extends Control

@onready var start_button = $VBoxContainer/StartButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var sound_button = $VBoxContainer/SoundButton



func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Level.tscn")


func _on_sound_button_pressed():
	pass # Replace with function body.


func _on_quit_button_pressed():
	get_tree().quit()
