extends Button
export var is_quit: bool = false
export(String) var newScenePath = "res://LevelScenes/Game.tscn"

func _ready():
	self.connect("pressed", self, "_button_pressed")


func _button_pressed():
	print("clicked")
	if (not is_quit):
		get_tree().change_scene(newScenePath)
	else:
		get_tree().quit()
