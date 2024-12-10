class_name Enemy
extends CharacterBody2D

const SPEED = 50.0
const DAMAGE = 8
const SCORE_VALUE = 50

var health = 10
var player_pos
var target_pos

@onready var player = get_parent().get_node("Player")
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var hitbox = $hitbox

func _physics_process(delta):
	follow_player(delta)
	handle_damage_to_player()
	handle_animations()

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
