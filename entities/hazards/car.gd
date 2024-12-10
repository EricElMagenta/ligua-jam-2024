extends Area2D
class_name Car

const SPEED = 300.0
const DAMAGE = 20

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var player = get_parent().get_node("Player")
@onready var hitbox = $"."

func _ready():
	animated_sprite_2d.frame = int(randi_range(0,4)) # Sprite random

func _physics_process(delta):
	position.x -= SPEED * delta
	handle_damage()

func handle_damage():
	for body in hitbox.get_overlapping_bodies():
		if body is Player && !player.damage_blink:
			player.health.value -= DAMAGE
			player.on_take_damage()
		
