extends Node2D

var enemiesAlive = 0

var levelNum = 0
var rectLimit = [5, 12]
onready var playerScene = preload("res://scenes/ducktor.tscn")
onready var duck_enemy = preload("res://scenes/InfectedDuck.tscn")
onready var toad_enemy = preload("res://scenes/Toad.tscn")
onready var rat_enemy = preload("res://scenes/Rat.tscn")
onready var player

export var music_path = "/root/World/Music_Player"
export var win_scene_path = "res://LevelScenes/Win.tscn"

var boss_here = false

onready var hippo_boss = preload("res://scenes/Hippocrates.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	_clear_tilemap()
	_create_layout($base)
	player = playerScene.instance()
	player.get_node("Area2D").connect("body_entered", self, "_exit_level")
	add_child(player)
	_make_level($base,$walls)
	
	

		
func _create_layout(tm : TileMap):
	_create_rect(rectLimit[0], rectLimit[1], tm)
	levelNum += 1
	for i in rand_range(3,5):
		var pos = _get_exits(tm)["end"]
		_create_rect(pos.x,pos.y, tm)
	# setting entrance and exit
	var exits = _get_exits(tm)
	exits["start"].x -= 1
	tm.set_cellv(exits["start"],2)
	exits["end"].x += 1
	tm.set_cellv(exits["end"],3)

func _get_exits(tm: TileMap):
	var rectangle = tm.get_used_rect()
	var rightSide = []
	var leftSide = []
	for i in range(rectangle.end.y):
		var currCell = Vector2(rectangle.position.x, rectangle.position.y+i)
		if (tm.get_cellv(currCell) != -1):
			leftSide.append(currCell)
		currCell.x = rectangle.end.x-1
		if (tm.get_cellv(currCell) != -1):
			rightSide.append(currCell)
	return ({"start": leftSide.pop_at((randi()%(len(leftSide)-2))+1), "end":null if rightSide.size()==0 else rightSide.pop_at((randi()%(len(rightSide)-2))+1)})

func _clear_tilemap():
	#clears all tilemaps
#	get_tree().call_group("tilemap","clear")
	$base.clear()
	$walls.clear()

# making level with autotiles
func _make_level(baseTM: TileMap, fillTM: TileMap):
	for cell in baseTM.get_used_cells():
		fillTM.set_cellv(cell,0)
	# updating whole region (so tiles will update properly)
	fillTM.update_bitmask_region(baseTM.get_used_rect().position, baseTM.get_used_rect().end)
	# setting start cell
	fillTM.set_cellv(baseTM.get_used_cells_by_id(2)[0], 0,false, false, false, Vector2(9,2))
	# setting end cell
	
	 # setting start cell
	var start = baseTM.get_used_cells_by_id(2)[0]
	start.x += 1
	fillTM.set_cellv(start, 0, false, false, false, Vector2(10,4))
	# setting end cell
	var end = baseTM.get_used_cells_by_id(3)[0]
	end.x -= 1
	fillTM.set_cellv(end, 0, false, false, false, Vector2(5,4))
	
	
	var enemy_num = int(clamp(rand_range(1, 3) + levelNum, 1, 7))
	spawn_enemies(enemy_num)
	# spawning player
	_spawn_player(baseTM, baseTM.get_used_cells_by_id(2)[0])
	
# resets camera boundaries + spawns in palyer position
func _spawn_player(tm : TileMap, vectorCoordinates:Vector2):
	# offset to spawn offscreen then i can animate the player walking through (not done yet)
	vectorCoordinates.y += 0.5
	vectorCoordinates.x += 2
	player.set_position(vectorCoordinates * 32)
	var camera = player.get_node("Camera2D")
	var tmSize = tm.get_used_rect()
	var tmCellSize = tm.cell_size
	var offset = 1
	camera.limit_left = (tmSize.position.x) * tmCellSize.x
	camera.limit_right = (tmSize.end.x) * tmCellSize.x
	camera.limit_top = (tmSize.position.y - offset) * tmCellSize.y
	camera.limit_bottom = (tmSize.end.y + offset)* tmCellSize.y

# connected signal whenever the player finishes the level





# creating rectangles for levels
func _create_rect(xCoord,yCoord, tm:TileMap):
	var length = int(rand_range(rectLimit[0],rectLimit[1]-2))
	var width = int(rand_range(rectLimit[0],rectLimit[1]))
	xCoord -= width/2
	yCoord -= length/2
	for y in range(length):
		for x in range(width):
			tm.set_cell(xCoord+x,yCoord+y,0)
	



func spawn_enemies(enemy_num):
	enemiesAlive += enemy_num
	var possible_coords = $walls.get_used_cells()
	var valid_coords = []
	for i in range(possible_coords.size()):
		if possible_coords[i].x >= $walls.get_used_rect().position.x + ($walls.get_used_rect().size.x * 0.2):
			valid_coords.append(possible_coords[i])

	
	valid_coords.shuffle()
	var enemy_index_list = []
	for i in range(enemy_num):
		var enemy = get_enemy().instance()
		enemy.connect("defeated", self, "decrease_enemies_alive")
		valid_coords[i].x += 0.5
		valid_coords[i].y += 0.5
		enemy.set_position(valid_coords[i] * 32)
		add_child(enemy)
	

func get_enemy():
	var enemies = ["duck", "toad", "rat"]
	var enemy_type = int(rand_range(0, 3))
	
	match (enemies[enemy_type]):
		"duck":
			return duck_enemy
		"toad":
			return toad_enemy
		"rat":
			return rat_enemy

func decrease_enemies_alive():
	enemiesAlive -= 1
	if enemiesAlive == 0 and !boss_here:
		var end = $base.get_used_cells_by_id(3)[0]
		end.x -= 1
		$walls.set_cellv(end, 0, false, false, false, Vector2(1,4))
		
	elif enemiesAlive == 0 and boss_here:
		get_tree().change_scene(win_scene_path)
		#Unlock level or something
		

func _create_boss_level(baseTM : TileMap, fillTM : TileMap):
	var sp = Vector2(1,16)
	# making hallway
	for x in range(10):
		for y in range(3):
			fillTM.set_cell(x,y+sp.y-1,0)
	# making spawnpoint
	baseTM.set_cellv(sp,2)
	# making boss arena
	var rect = Vector2(12,10)
	for x in range(rect.x):
		for y in range(rect.y):
			fillTM.set_cell(x+10,y+(sp.y)-int(rect.y/2),0)
	fillTM.update_bitmask_region(fillTM.get_used_rect().position, fillTM.get_used_rect().end)
		
	_spawn_player(fillTM, baseTM.get_used_cells_by_id(2)[0])
	
	spawn_boss()

func spawn_boss():
	enemiesAlive = 1
	
	var boss = hippo_boss.instance()
	var position = Vector2(16.2, 16) * 32
	boss.set_position(position)
	add_child(boss)
	boss.connect("defeated", self, "decrease_enemies_alive")
	var audio_player = get_node(music_path)
	audio_player.change_song("boss")
	#spawn_enemies(3)
	enemiesAlive += 3
	
	var valid_coords = [Vector2(15, 16), Vector2(17.2, 16), Vector2(16, 12)]


	
	valid_coords.shuffle()
	var enemy_index_list = []
	for i in range(3):
		var enemy = get_enemy().instance()
		enemy.connect("defeated", self, "decrease_enemies_alive")
		valid_coords[i].x += 0.5
		valid_coords[i].y += 0.5
		enemy.set_position(valid_coords[i] * 32)
		add_child(enemy)
	boss_here = true

	

func _exit_level(body):
	if (body is TileMap):
		get_tree().call_group("Enemy", "queue_free")
		_clear_tilemap()
		if levelNum != 5:
			_create_layout($base)
			_make_level($base,$walls)
		else:
			_create_boss_level($base, $walls)
		
	
	


