extends StaticBody2D


# Called when the node enters the scene tree for the first time.
@onready var _animated_sprite = $AnimatedSprite2D
@onready var hp = $HpComponent
var pickable = preload("res://Scenes/Pickable.tscn")
var opened = false

signal loot(loot)

func _ready():
	pass

func generate_loot():
	# var rng = RandomNumberGenerator.new()
	# rng.randi_range(1, 2)
	var loot = []
	loot.append(pickable.instantiate())
	for l in loot:
		add_child(l)	
		l.generate()
		# TODO: animation
		l.position = Vector2(0, 30)
	


func _on_hp_component_char_dead():
	_animated_sprite.play("open")
	opened = true
	# TODO: check for loot
	# loot.emit("hp")
	generate_loot()
