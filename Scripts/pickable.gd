extends Area2D


@onready var sprite = $Sprite
@onready var collision = $Collision
@onready var animation_player = $AnimationPlayer
@onready var cost_label = $Cost


enum TYPE {HP, Coin, ATK, None=-1}

@export var value: int = 1
@export var type: TYPE
@export var cost: int = -1

signal item_bought(player)

func _ready():
	if type == TYPE.None:
		return
	set_type()
	animation_player.play("floating")
	if cost > -1:
		cost_label.text = str(cost)
		cost_label.visible = true

func drop():
	set_type()
	animation_player.play("dropping")

		
func generate():
	# type = TYPE.keys()[randi() % TYPE.size()]
	monitoring = false
	var rng = RandomNumberGenerator.new()
	type = rng.randi_range(0, TYPE.size() - 1)
	drop()
	
func set_type():
	if type != TYPE.Coin:
		collision.scale *= 1.5
	match type:
		TYPE.Coin:
			sprite.play("coin")
		TYPE.HP:
			sprite.play("hp_potion")
		TYPE.ATK:
			sprite.play("atk_potion")
	
func _on_body_entered(body):
	if not body.has_method("get_coins"):
		return
	match type:
		TYPE.Coin:
			body.get_coins(value)
		TYPE.HP:
			body.hp.heal(value)
		TYPE.ATK:
			body.atk.add_amplifier(1, 10.0)
	if cost > -1 and body.coins >= cost:
		body.spend_coins(cost)
		item_bought.emit(body)
	queue_free()


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "dropping":
		animation_player.play("floating")
		monitoring = true

func check_cost(budget):
	if budget >= cost:
		monitoring = true
		cost_label.label_settings.font_color = Color(1, 1, 1)
	else:
		monitoring = false
		cost_label.label_settings.font_color = Color(1, 0, 0)
