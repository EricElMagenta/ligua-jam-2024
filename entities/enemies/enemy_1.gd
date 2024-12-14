class_name Enemy
extends CharacterBody2D

const SPEED = 50.0
const DAMAGE = 8
const SCORE_VALUE = 50
const ROTATION_CRASH = 2
const POWER_UP_DROP_RATE = 0.2


var health = 10
var player_pos
var target_pos
var crashed = false
var weapons_spawn = ["machinegun", "blowgun"]

# AUDIO
@onready var sfx_car_crash = $SFX/SFXCarCrash


@onready var player = get_parent().get_node("Player")
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var hitbox = $hitbox
@onready var collision_shape_2d = $hitbox/CollisionShape2D

func _physics_process(delta):
	if !crashed: follow_player(delta)
	else: 
		a_la_mierda()
	
	handle_damage_to_player()
	handle_animations()
	if health <= 0:
		if randf() < POWER_UP_DROP_RATE: 
			spawn_power_up()

# SEGUIR AL JUGADOR
func follow_player(delta):
	player_pos = player.position
	target_pos = (player_pos - position).normalized()
	
	if position.distance_to(player_pos) > 1:
		position += target_pos * SPEED * delta
		
func handle_animations():
	#if target_pos.y > 0: animated_sprite_2d.play("walk-down")
	#else: animated_sprite_2d.play("walk-up")
	animated_sprite_2d.play("walk-side")
	if target_pos.x < 0: scale.x = -1
	else: scale.x = 1

func handle_damage_to_player():
	for body in hitbox.get_overlapping_bodies():
		if body is Player && !player.damage_blink:
			player.health.value -= DAMAGE
			player.on_take_damage()

func _on_hitbox_area_entered(area):
	if area is Car:
		sfx_car_crash.play()
		crashed = true
		
func a_la_mierda():
	collision_shape_2d.disabled = true
	rotation += ROTATION_CRASH
	position += Vector2(-5, -5)
	

func spawn_power_up():
	var random_power_up = weapons_spawn[randi() % weapons_spawn.size()]
	var power_up_instance = load("res://entities/power-ups/power_up_" + random_power_up + ".tscn").instantiate()
	power_up_instance.position = position
	call_deferred("add_sibling", power_up_instance)


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
