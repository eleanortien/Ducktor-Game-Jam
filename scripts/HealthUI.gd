extends Control

export var player_path = "../../.."
export var end_scene_path = "res://LevelScenes/End.tscn"
export var song_player_path = "/root/World/Music_Player"
export var heart_x_size = 11
export var heart_y_size = 10

var hearts: int = 5 setget set_hearts
var max_hearts: int = 5 setget set_max_hearts

var player: Player

onready var heartUIFull = $HeartUIFull
onready var heartUIEmpty = $HeartUIEmpty 


func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	
	if hearts <= 0:
		get_tree().change_scene(end_scene_path)
	
	if hearts == 1:
		var audio_player = get_node(song_player_path)
		audio_player.change_song("low_health")

	if (heartUIFull != null):
		heartUIFull.rect_size.x = hearts * heart_x_size
		

func set_max_hearts(value: int):
	max_hearts = max(value, 1)
	if (heartUIEmpty != null):
		heartUIEmpty.rect_size.x = max_hearts * heart_x_size
	
func _ready():
	player = get_node(player_path)
	self.max_hearts = player.get_max_health()
	self.hearts = self.max_hearts
	player.connect("change_health", self, "set_hearts")



func change_health_UI(amount):
	pass
