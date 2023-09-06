extends AudioStreamPlayer2D


onready var battle_song: AudioStream = preload("res://assets/music/Battle_Music.mp3")
onready var low_health_song: AudioStream = preload("res://assets/music/Low_Health.wav")
onready var final_boss_song: AudioStream = preload("res://assets/music/The Hippocrates.mp3")


enum song {battle, low_health, boss}
var curr_song: int = song.battle


func _ready():
	self.stream = battle_song
	self.play()


func change_song(new_song: String):
	if str(curr_song) != new_song:
		match(new_song):
			"battle":
				self.stream = battle_song
				curr_song = song.battle
			"low_health":
				self.stream = low_health_song
				curr_song = song.low_health
			"boss":
				self.stream = final_boss_song
				curr_song = song.boss
		
		self.play()
	
