extends KinematicBody2D
onready var animator = $AnimatedSprite

export var x_velocity = 1
export var y_velocity = 0
onready var velocity = Vector2(x_velocity,y_velocity)

var speed = 300
export var damage_amount: int = 1


func _physics_process(delta):
	var collison_info = move_and_collide(velocity.normalized()*delta*speed)
	if collison_info:
		animator.play("explode")
		yield(get_tree().create_timer(0.2), "timeout")
		queue_free()
		
		
func get_damage() -> int:
	return damage_amount
