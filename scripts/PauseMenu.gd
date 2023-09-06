extends Control

var is_paused: bool = false setget set_is_paused

onready var resume_button = $Image/ResumeButton

func _ready():
	visible = false
	resume_button.connect("pressed", self, "on_resume_pressed")

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		self.is_paused = !is_paused
		
		
func set_is_paused(value):
	is_paused = value
	get_tree().paused = is_paused
	visible = is_paused

func on_resume_pressed():
	set_is_paused(false)
