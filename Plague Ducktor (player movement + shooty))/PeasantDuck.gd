extends KinematicBody2D

export (int) var speed = 80

var velocity = Vector2()
onready var ducktor = $AnimatedSprite


func _ready():
	pass
	
func get_input():
	velocity = Vector2()
	if Input.is_action_pressed("right"):
		velocity.x += 1
		ducktor.play("walk right")
	if Input.is_action_pressed("left"):
		velocity.x -= 1
		ducktor.play("walk left")
	if Input.is_action_pressed("down"):
		velocity.y += 1
		ducktor.play("walk back")
	if Input.is_action_pressed("up"):
		velocity.y -= 1
		ducktor.play("walk forward")
	velocity = velocity.normalized() * speed

func _physics_process(delta):
	get_input()
	velocity = move_and_slide(velocity)
	var collision_info = move_and_collide(velocity * delta)
	if collision_info:
		var collision_point = collision_info.get_position()
	if velocity == Vector2.ZERO:
		ducktor.stop()
