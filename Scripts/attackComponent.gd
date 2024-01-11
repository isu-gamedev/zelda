extends Area2D

@onready var atkCd = $AtkCd
@onready var timer = $Timer
@onready var hitbox = $Hitbox

@export var atk: int = 1
@export var atk_cd: float = 1
@export var opens_chests = false


signal attack_done(damage)
signal attack_started()
signal amplifier_added(amplifier)
signal amplifier_removed(amplifier)

func _ready():
	atkCd.wait_time = atk_cd


func attack():
	if get_parent().name == "player":
		print(atkCd.wait_time)
	if atkCd.time_left > 0:
		return
	hitbox.disabled = false
	# atkCd.start()
	timer.start()
	attack_started.emit()


func add_amplifier(value, time):
	var scene = load("res://Scenes/StatusEffect.tscn")
	var amplifier = scene.instantiate()
	amplifier.add_to_group("atk_amplifiers")
	add_child(amplifier)
	amplifier.value = value
	amplifier.start_timer(time)	
	amplifier_added.emit(amplifier)
	amplifier.progress_bar.visible = false

func _on_attack_timer_timeout():
	hitbox.disabled = true


func _on_body_entered(body):
	if body.name == "TileMap":
		return
	if body.collision_layer > 3:
		if opens_chests:
			body.hp.damage(1)
		return
	var amplifiedAtk = atk
	var amplifiers = get_tree().get_nodes_in_group("atk_amplifiers")
	for a in amplifiers:
		if self != a.get_parent():
			continue
		if a.type == a.TYPE.ADD:
			amplifiedAtk += a.value
		else:
			amplifiedAtk *= a.value
	attack_done.emit(amplifiedAtk)
	if body.has_node("HpComponent"):
		body.hp.damage(amplifiedAtk)
	
func get_hitbox_size():
	return hitbox.shape.get_size()


func _on_timer_timeout():
	hitbox.disabled = true
	atkCd.start()
