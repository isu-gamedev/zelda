extends CharacterBody2D

const DIR_UP = Vector2(0, -1)
const DIR_DOWN = Vector2(0, 1)
const DIR_LEFT = Vector2(-1, 0)
const DIR_RIGHT = Vector2(1, 0)

var coin = preload("res://Scenes/Pickable.tscn")
 
@onready var hp = $HpComponent
@onready var atk = $AttackComponent
@onready var _animated_sprite = $sprite
@onready var _path = get_parent()
@onready var agro = $Area2D

var speed = 30

var direction = Vector2(0, 0)
var action = "walk"
var target = null
signal health_changed(old_hp, new_hp)

var currentTarget: CharacterBody2D = null

func _get_animation_rotation(dir):
	var side = _side_from_direction(dir)
	if side == "right":
		_animated_sprite.flip_h = false
		side = "side"
	elif side == "left":
		_animated_sprite.flip_h = true
		side = "side"
	return side
	
func _side_from_direction(dir):
	if dir.x == 1:
		return "right"
	elif dir.x == -1:
		return "left"
	elif dir.y == -1:
		return "up"
	else:
		return "down"

func play_animation():
	match action:
		"dying": 
			_animated_sprite.play("death")
		"walk":
			_animated_sprite.play("walk")
		"attack":
			_animated_sprite.play("attack")
		"damage":
			_animated_sprite.play("take_hit")

func _physics_process(delta):	
	play_animation()
	
	if action == "dying" or action == "dead" or action == "damage":
		return
	
	if target != null:
		var dir = (target.global_position - global_position).normalized()
		if (target.global_position - global_position).length() > 500:
			return_to_path()
		velocity = dir * speed * 2
		move_and_slide()
	else:
		_path.set_progress(_path.get_progress() + speed / 2 * delta)
	atk.attack()


func _on_sprite_animation_finished():
	if action == "dying":
		#queue_free()
		action = "dead"
		pass
	elif action == "damage":
		action = "walk" 


func _on_hp_component_damage_taken(damage):
	action = "damage"


func _on_hp_component_char_dead():
	_drop_loot()
	action = "dying"


func _on_area_2d_body_entered(body):
	if body.has_method("read_input"):
		target = body
		_path.loop = false

func return_to_path():
	target = null
	position = Vector2(0 ,0)
	_path.set_progress(0)
	_path.loop = true
	
func follow():
	var curve = _path.get_parent().get_curve() 
	curve.remove_point(1)
	curve.add_point(target.get_position())	

func _drop_loot():
	var rng = RandomNumberGenerator.new()
	var odds = rng.randf()
	if odds < 0.5:
		return
	var l = coin.instantiate()
	add_child(l)
	l.position = Vector2(position)
	l.type = l.TYPE.Coin
	l.drop()
