extends KinematicBody2D
class_name Boss_Enemy

export var enemy_health: int = 5
export var damage_amount: int = 1
export var shoot_cooldown: int = 1


export var player_path = "../ducktor"
const slimePath = preload("res://scenes/slime.tscn")

onready var defeat_sound = preload("res://assets/sfx/hippo sounds.wav")
onready var shoot_sound = preload("res://assets/sfx/hippo slime balls (1).wav")

onready var audio_player = $audio_player

signal defeated()


var player 

onready var hit_area = $hit_box

onready var animator = $AnimatedSprite



enum state {shoot, defeated}
var curr_state: int = state.shoot


# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(false)
	get_node("AnimationPlayer").play("Spawn")
	#audio_player.stream = shoot_sound

	hit_area.connect("body_entered", self, "on_bullet_detect")
	yield(get_tree().create_timer(2), "timeout")
	set_physics_process(true)




func _physics_process(delta):
	
	player = get_node(player_path)
	
			
	match(curr_state):
		state.shoot:
			animator.play("Shoot")
			shoot()
			move_and_slide(Vector2.ZERO)
			
			
		state.defeated:
			animator.play("Defeated")
			move_and_slide(Vector2.ZERO)
			
func on_bullet_detect(body: KinematicBody2D)-> void:
	if body.is_in_group("Player_Bullet"):
		change_health(-1)

	
		
	

	
	


#Freezes physics function for a set amount of time
func pause_movement_timer():
	set_physics_process(false)
	yield(get_tree().create_timer(shoot_cooldown), "timeout")
	set_physics_process(true)

func change_health(amount: int)-> void:
	enemy_health += amount
	if enemy_health == 0:
		emit_signal("defeated")
	if (enemy_health <= 0):
		curr_state = state.defeated
		play_defeat_sound()

func get_damage() -> int:
	if curr_state == state.defeated:
		return 0
	return damage_amount

func play_defeat_sound():
	if audio_player.playing:
		audio_player.stop()
	audio_player.stream = defeat_sound
	audio_player.play()

func shoot():
	var slime = slimePath.instance()
	get_parent().add_child(slime)
	slime.position = $slime_spawn.global_position
	pause_movement_timer()
