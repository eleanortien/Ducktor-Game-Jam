extends KinematicBody2D
class_name Player

export (int) var max_speed = 125
export (int) var player_max_health = 5
onready var player_health: int = player_max_health
export (int) var hurt_cooldown = 1
export (float) var shoot_cooldown = 0.5
export (float) var speed_reduction = 0.6

const bulletpath = preload("res://scenes/bullet.tscn")

onready var speed: int = max_speed
var velocity = Vector2()
var taking_damage: bool = false
var damage_to_take: int = 0
onready var ducktor = $AnimatedSprite
onready var hurtbox = $hurtbox

onready var audio_player = $sfx_player

var on_shoot_cooldown : bool = false

signal change_health(amount)

#Sounds
onready var shoot_sound: AudioStream = preload("res://assets/sfx/player shooty.wav")
onready var quack_sound: AudioStream = preload("res://assets/sfx/quack(v).wav") 
onready var walk_sound: AudioStream = preload("res://assets/sfx/duck walking.wav")


enum state {play, defeated}
var curr_state: int = state.play

func get_max_health() -> int:
	return player_max_health

func _ready():
	hurtbox.connect("body_entered", self, "on_body_collision")
	hurtbox.connect("body_exited", self, "on_body_collision_end")
	
	
func get_input():
	velocity = Vector2()
	if Input.is_action_pressed("right"):
		velocity.x += 1
		ducktor.play("walk right")
		if !audio_player.playing:
			audio_player.stream = walk_sound
			audio_player.play()
			
	if Input.is_action_pressed("left"):
		velocity.x -= 1
		ducktor.play("walk left")
		if !audio_player.playing:
			audio_player.stream = walk_sound
			audio_player.play()
			
	if Input.is_action_pressed("down"):
		velocity.y += 1
		ducktor.play("walk back")
		if !audio_player.playing:
			audio_player.stream = walk_sound
			audio_player.play()
			
	if Input.is_action_pressed("up"):
		velocity.y -= 1
		ducktor.play("walk forward")
		if !audio_player.playing:
			audio_player.stream = walk_sound
			audio_player.play()
			
	if Input.is_action_pressed("click"):
		speed = max_speed * speed_reduction
		if on_shoot_cooldown == false:
			shoot_timer()
			shoot()
			
	if Input.is_action_just_released("click"):
		speed = max_speed
	if Input.is_action_pressed("quack"):
		audio_player.stop()
		audio_player.stream = quack_sound
		audio_player.play() 
	velocity = velocity.normalized() * speed

func _physics_process(delta):
	match(curr_state):
		state.play:
			get_input()
			velocity = move_and_slide(velocity)
			var collision_info = move_and_collide(velocity * delta)
			if collision_info:
				var collision_point = collision_info.get_position()
			if velocity == Vector2.ZERO:
				ducktor.stop()
				if audio_player.playing and audio_player.stream == walk_sound:
					audio_player.stop()
				
				
			
		state.defeated:
			move_and_slide(Vector2.ZERO)
			
		
func _process(delta):
	if (taking_damage == true):
		change_player_health(damage_to_take * -1)
				
func _custom_process(delta):
	$Node2D.look_at(get_global_mouse_position())
	
func on_body_collision(body: KinematicBody2D) -> void:
	
	if body.is_in_group("Enemy") or body.is_in_group("Boss_Enemy") or body.is_in_group("Enemy_Bullet"):
		damage_to_take = body.get_damage()
	
		taking_damage = true
		
		#Knockback
		var direction = (body.position - position).normalized() * -20
		move_and_slide(direction)
	

		
	
func on_body_collision_end(body: KinematicBody2D) -> void:
	if body.is_in_group("Enemy") or body.is_in_group("Boss_Enemy") or body.is_in_group("Enemy_Bullet"):
		taking_damage = false
		damage_to_take = 0
		

func change_player_health(amount):
	if amount != 0:
		audio_player.stream = quack_sound
		audio_player.play()
	
	
	if (player_health + amount <= 0):
		player_health = 0
		curr_state = state.defeated
		
	else:
		player_health += amount
	
	emit_signal("change_health", player_health)

	set_process(false)
	yield(get_tree().create_timer(hurt_cooldown), "timeout")
	set_process(true)
	

func shoot_timer():
	on_shoot_cooldown = true
	yield(get_tree().create_timer(shoot_cooldown), "timeout")
	on_shoot_cooldown = false

func shoot():
	audio_player.stream = shoot_sound
	audio_player.play()
	var bullet = bulletpath.instance()
	get_parent().add_child(bullet)
	bullet.position = $Node2D/Position2D.global_position
	bullet.velocity = get_global_mouse_position() - bullet.position

