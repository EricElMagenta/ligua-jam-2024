class_name Projectile
extends Area2D

const SPEED = 5
const DEFAULT_SPEED = 3
const ROTATION_SPEED = 0.2

var damage = 10
var spawn_pos : Vector2 # Posición de spawn
var target_pos : Vector2 # Objetivo (donde clickeó el jugador)
var weapon_index = 0

# Hitbox del dulce
@onready var collision_shape_2d = $CollisionShape2D
@onready var animated_sprite_2d = $AnimatedSprite2D

# Spawnear en el jugador
func _ready():
	global_position = spawn_pos
	animated_sprite_2d.frame = int(randi_range(0,4)) # Sprite random

func _physics_process(delta):
	rotation += ROTATION_SPEED
	if weapon_index == 0: default_shooting()
	elif weapon_index == 1: machinegun_shooting()
	elif weapon_index == 2: blowgun_shooting()

###################################################### FUNCIONES AUXILIARES ###################################################
	# Lanzamiento por defecto
func default_shooting():
	# Se dirige a donde hizo click el jugador y desparece
	position = position.move_toward(target_pos, DEFAULT_SPEED)
	if position == target_pos: 
		explode()

func machinegun_shooting():
	position = position.move_toward(target_pos, SPEED)
	if position == target_pos: 
		explode()
		
func blowgun_shooting():
	position = position.move_toward(target_pos, SPEED*2)
	if position == target_pos: 
		explode()

func explode():
	rotation = 0
	collision_shape_2d.set_deferred("disabled", true)
	animated_sprite_2d.play("SPLORT!")
	await get_tree().create_timer(0.5).timeout
	queue_free()

####################################################### SEÑALES ##############################################################
func _on_body_entered(body):	
	# Daña a los enemigos si son enemigos
	if body && body is Enemy:
		body.health -= damage
		if weapon_index != 2: queue_free()
		# Elimina el enemigo si se queda sin vida
		if body.health <= 0:
			body.queue_free()
			return
		
