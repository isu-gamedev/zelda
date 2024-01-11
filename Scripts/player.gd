extends CharacterBody2D

enum Dirs {DOWN = 0, UP = 1, RIGHT = 2, LEFT = 3} 
const DIR_UP = Vector2(0, -1)
const DIR_DOWN = Vector2(0, 1)
const DIR_LEFT = Vector2(-1, 0)
const DIR_RIGHT = Vector2(1, 0)

@onready var _animated_sprite = $AnimatedSprite2D
@onready var hp = $HpComponent
@onready var atk = $AttackComponent
@onready var hitbox = $bodyCollision

@export var Speed = 600
@export var coins = 0

# Variables
var direction = Vector2(0, 0)
var action = "idle"
var prev_action = "idle"
var auto_move = false # TODO: when entering from another room

# Signals
signal health_changed(value)
signal coins_changed(new_value)
signal amplifier_added(amplifier)
signal amplifier_removed(amplifier)

func _ready():
	for i in hp.currHp - 1:
		health_changed.emit(1)
	coins_changed.emit(coins)
	
func read_input():
	velocity.x = 0
	velocity.y = 0
	var curr_dir = Vector2(0, 0)
	var moving = false
	if Input.is_action_pressed("up"):
		curr_dir += DIR_UP
		moving = true
	if Input.is_action_pressed("down"):
		curr_dir += DIR_DOWN		
		moving = true
	if Input.is_action_pressed("right"):
		curr_dir += DIR_RIGHT
		moving = true
	if Input.is_action_pressed("left"):
		curr_dir += DIR_LEFT
		moving = true
	
	if Input.is_action_just_pressed("hit"):
		atk.attack()
	
	elif action != "hit":
		action = "walk"
		
	if moving:
		direction = curr_dir
		rotate_hitbox(_side_from_direction(direction))
		velocity = direction.normalized() * Speed
	elif action != "hit":
		action = "idle"
	
	play_animation()
		

func _on_animated_sprite_2d_animation_finished():
	if action == "hit":
		_animated_sprite.speed_scale = 1		
		action = ""

func play_animation():
	var animation_dir = _get_animation_rotation(direction)
	var animation = action + "_" + animation_dir
	_animated_sprite.play(animation)
	
func _get_animation_rotation(dir):
	var side = _side_from_direction(dir)
	match side:
		Dirs.RIGHT:
			_animated_sprite.flip_h = false
			side = "side"
		Dirs.LEFT:
			_animated_sprite.flip_h = true
			side = "side"
		Dirs.UP:
			side = "up"
		Dirs.DOWN:
			side = "down"
	return side
	
func _side_from_direction(dir):
	if dir.x == 1:
		return Dirs.RIGHT
	elif dir.x == -1:
		return Dirs.LEFT
	elif dir.y == -1:
		return Dirs.UP
	else:
		return Dirs.DOWN
	
func rotate_hitbox(dir):
	match dir:
		Dirs.LEFT:
			atk.set_position(Vector2((-atk.get_hitbox_size().x - hitbox.shape.get_radius()) / 2, 0))
		Dirs.RIGHT:
			atk.set_position(Vector2((atk.get_hitbox_size().x + hitbox.shape.get_radius()) / 2, 0))
		Dirs.UP:
			atk.set_position(Vector2(0, (-atk.get_hitbox_size().y - hitbox.shape.get_height() / 2) / 2))
		Dirs.DOWN:
			atk.set_position(Vector2(0, (atk.get_hitbox_size().y + hitbox.shape.get_height() / 2) / 2))	

	
func hit_animation():
	if int(hp.timer.time_left * 10) % 2 == 0:
		_animated_sprite.modulate.a = 1.0
	else:
		_animated_sprite.modulate.a = 0.5
	

func _physics_process(delta):
	if hp.currHp == 0:
		return
	read_input()
	move_and_slide()
	# print(self.global_position)
	if hp.timer.time_left > 0:
		hit_animation()


func _on_chest_loot(loot):
	if loot == "hp":
		hp.heal(1)
		health_changed.emit(hp.currHp - 1, hp.currHp)

func _on_char_dead():
	_animated_sprite.play("death")

func _on_damage_taken(damage):
	health_changed.emit(-damage)


func _on_attack_component_attack_started():
	if action != "hit":
		prev_action = action
		action = "hit"
	_animated_sprite.speed_scale = 2.5


func _on_attack_component_attack_done(damage):
	if velocity.length() > 0:
		prev_action = "move"
	else:
		prev_action = "idle"

func get_coins(value):	
	coins += value
	coins_changed.emit(coins)

func spend_coins(value):
	coins -= value
	coins_changed.emit(coins)


func _on_hp_component_healed(hp):
	health_changed.emit(hp)


func _on_attack_component_amplifier_added(amplifier):
	amplifier_added.emit(amplifier)


func _on_attack_component_amplifier_removed(amplifier):
	amplifier_removed.emit(amplifier)
