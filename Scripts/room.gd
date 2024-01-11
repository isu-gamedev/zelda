extends Node

@onready var tilemap = $TileMap
@onready var l_enter = $LEnter
@onready var r_enter = $REnter
@onready var b_enter = $BEnter
@onready var t_enter = $TEnter 
@onready var area = $Area 

var rooms = {
	"left": null,
	"right": null,
	"top": null,
	"bottom": null	
}

var dirs2layers = {
	"left": 2,
	"right": 3,
	"top": 4,
	"bottom": 5	
}

var dirs2spawns = {
	"left": null,
	"right": null,
	"top": null,
	"bottom": null	
}

func _ready():
	dirs2spawns = {
		"left": l_enter,
		"right": r_enter,
		"top": t_enter,
		"bottom": b_enter	
	}

func _process(delta):
	# camera limits based on areas
	pass
	
func enter_from(room, player):
	var dir = rooms.find_key(room)
	var spawn = dirs2spawns[dir]
	player.global_position = spawn.global_position
	
	
func enter(player):
	player.global_position = self.global_position
	
func add_room(room, dir = null):
	if dir == null:
		var left_dirs = []
		for d in rooms:
			if rooms[d] == null:
				left_dirs.append(d)
		randomize()
		left_dirs.shuffle()
		dir = left_dirs[0]
	rooms[dir] = room
	
	tilemap.clear_layer(dirs2layers[dir])
	return dir

func _on_area_body_exited(body):
	if body.name != "player":
		return
	var min_dist = body.global_position.distance_to(r_enter.global_position)
	var side = "right"
	for d in dirs2spawns:
		var new_dist = body.global_position.distance_to(dirs2spawns[d].global_position) 
		if new_dist < min_dist:
			min_dist = new_dist
			side = d
	if rooms[side] == null:
		return
	rooms[side].enter_from(self, body)

func _on_area_body_entered(body):
	if body.name != "player":
		return
	var pickables = get_tree().get_nodes_in_group("Pickables")
		
	for p in pickables:
		p.check_cost(body.coins)


func _on_pickable_item_bought(player):
	var pickables = get_tree().get_nodes_in_group("Pickables")
		
	for p in pickables:
		p.check_cost(player.coins)
