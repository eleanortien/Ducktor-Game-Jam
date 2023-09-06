extends KinematicBody2D
class_name Enemy

export var enemy_health: int = 5
export var damage_amount: int = 1
export var speed = 50
export var chase_speed = 100
export var move_radius = 50
export var max_wait = 3
export var min_wait = 1
export var player_path = "../ducktor"
export var sensing_radius = 150
export var defeat_sound_path: String = "res://assets/sfx/mouse.wav"

signal defeated()

onready var audio_player = $audio_player
const err = 1


var curr_dest = Vector2()
var player 
var rng = RandomNumberGenerator.new()


onready var search_player_area = $Area2D
onready var sensing_area = $Area2D/sensing_rad
onready var animator = $Position2D/AnimatedSprite
onready var flipper = $Position2D
onready var hit_box = $hit_box


enum state {idle, moving, chase, defeated}
var curr_state: int = state.idle


# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(false)
	get_node("AnimationPlayer").play("Spawn")
	rng.randomize()
	audio_player.stream = load(defeat_sound_path)
	sensing_area.shape.set_radius(sensing_radius)
	search_player_area.connect("body_entered", self, "on_player_detect")
	search_player_area.connect("body_exited", self, "on_player_exit")
	hit_box.connect("body_entered", self, "on_bullet_detect")
	yield(get_tree().create_timer(rng.randi_range(2, max_wait)), "timeout")
	set_physics_process(true)

#Start in idle mode
#Wait random time to begin moving
#Generate random destination and move towards it (move back if hit wall)
#Switch to moving mode and walk towards destination
#Return to idle

#Scan continuously for player in radius
#Override all functions with chase mode until player out of radius
func _physics_process(delta):
	
	player = get_node(player_path)
	if ((player.position - position).length() < sensing_radius and curr_state != state.defeated):
		curr_state = state.chase
	
	match(curr_state):
		state.idle:
			animator.play("Idle")
			curr_dest = generate_destination() + position
			pause_movement_timer()
			curr_state = state.moving
			
			
		state.moving:
			animator.play("Walk")
			if (abs((curr_dest - position).length()) <= err):
				move_and_slide(Vector2.ZERO)
				curr_state = state.idle
			
			else:
				var direction = (curr_dest - position).normalized()
				move_and_slide(direction * speed)
				#Check for wall hit, change destination
				for index in get_slide_count():
					var collision = get_slide_collision(index)
					if collision.collider.is_in_group("Walls"):
						curr_dest = direction * -3 + position
					
				
				
				#Sprite direction
				if (direction.x >= 0.05):
					flipper.scale.x = 1
				elif (direction.x <= 0.05):
					flipper.scale.x = -1
				
		state.chase:
			animator.play("Walk")
			var direction = (player.position - position).normalized()
			move_and_slide(direction * chase_speed)
			
			#Sprite direction
			if (direction.x >= 0.05):
				flipper.scale.x = 1
			elif (direction.x <= 0.05):
				flipper.scale.x = -1
				
		state.defeated:
			animator.play("Defeated")
			move_and_slide(Vector2.ZERO)
			
func on_player_detect(body: KinematicBody2D)-> void:
	if body != null:
		if body.is_in_group("Player") and curr_state != state.defeated:
			curr_state = state.chase
			set_physics_process(true)

	
func on_player_exit(body: KinematicBody2D)-> void:
	if (body != null):
		if (body.is_in_group("Player") and curr_state != state.defeated):
			curr_state = state.idle

func on_bullet_detect(body: KinematicBody2D) -> void:
	if (body != null):
		if body.is_in_group("Player_Bullet"):
			change_health(-1)
	
		
func generate_destination():
	#Get point within radius
	var ran_vector = Vector2(rng.randi_range(move_radius * -1, move_radius), rng.randi_range(move_radius * -1, move_radius))
	return ran_vector

#Freezes physics function for a set amount of time
func pause_movement_timer():
	set_physics_process(false)
	yield(get_tree().create_timer(rng.randi_range(min_wait, max_wait)), "timeout")
	set_physics_process(true)

func change_health(amount: int)-> void:
	enemy_health += amount
	if enemy_health == 0:
		emit_signal("defeated")
		get_node("CollisionShape2D").disabled = true
	if (enemy_health <= 0):
		curr_state = state.defeated
		play_defeat_sound()

func get_damage() -> int:
	if curr_state == state.defeated:
		return 0
	return damage_amount

func play_defeat_sound():
	if audio_player.stream != null:
		audio_player.play()
