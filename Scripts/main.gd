extends Node2D

# @onready var test_room = $TestRoom
@onready var player = $player

var rooms = [preload("res://Scenes/Rooms/RoomL.tscn"), 
	preload("res://Scenes/Rooms/RoomSquare.tscn"),
	preload("res://Scenes/Rooms/RoomT.tscn")]
var shop_scene = preload("res://Scenes/Rooms/Shop.tscn")

var test_room = null

var rooms_cnt =0
var side2opposite = {
	"left" = "right",
	"right" = "left",
	"top" = "bottom",
	"bottom" = "top"	
}

var shop_placed = false

func _ready():
	test_room = load("res://Scenes/Rooms/TestRoom.tscn").instantiate()
	add_child(test_room)
	test_room.position = Vector2(0, -2000)	
	generate_rooms(3)
	# to_test_room()

func to_test_room():
	player.position = test_room.position
	
func generate_rooms(num = 4):
	var cnt = 1
	_generate_room(num - 1)
			
func _generate_room(num, from_room = null, from_dir = null):
	var rng = RandomNumberGenerator.new()
	
	# Choosing room type
	randomize()
	rooms.shuffle()
	var room = rooms[0].instantiate()
	
	# Placing the room
	room.position = Vector2(500, 500) * rooms_cnt # TODO: redo 
	
	# Adding to the tree
	add_child(room)
	
	# Adding existing exit
	if from_room != null:
		from_dir = from_room.add_room(room, from_dir)		
		room.add_room(from_room, side2opposite[from_dir])
	else:
		room.enter(player)
	
	# Generating other exits
	if num != 0:
		var max_exits = 3 if num >= 3 else num
		var exits_num = rng.randi_range(1, max_exits)
		num -= exits_num
		for i in range(exits_num):
			rooms_cnt += 1
			num = _generate_room(num, room)
	else:
		if shop_placed:
			return
		var shop = shop_scene.instantiate()
		rooms_cnt += 1
	
		# Placing the room
		shop.position = Vector2(500, 500) * rooms_cnt  # TODO: redo 
		
		# Adding to the tree
		add_child(shop)
		from_dir = room.add_room(shop, null)
		shop.add_room(room, side2opposite[from_dir])
		shop_placed = true
		
	return num
