extends CharacterBody2D
class_name Player

const SPEED = 100.0
const WEAPON = ["default", "machinegun"]

var health = 100 # VIDA
var can_shoot = true # COOLDOWN
var damage_blink = false # INVENCIBILIDAD DESPUÉS DE RECIBIR DAÑO
var weapon_index = 0
var current_anim_state = "idle"

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var projectile = load("res://entities/player/projectile.tscn")

func _physics_process(delta):
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	handle_movement(input_direction)
	handle_animation(input_direction)
	handle_shooting()
	move_and_slide()
	
	if health < 1: get_tree().reload_current_scene()

######################################################################### FUNCIONES AUXILIARES ############################################
func handle_movement(input_direction):
	if !is_on_wall() || !is_on_ceiling() : velocity = input_direction * SPEED

func on_take_damage():
	# Inmunidad post-daño
	damage_blink = true
	for i in 4: # Parpadear después de que te peguen
		self.modulate.a = 0
		await get_tree().create_timer(0.2).timeout
		self.modulate.a = 1
		await get_tree().create_timer(0.2).timeout
	damage_blink = false

func handle_shooting():
	if Input.is_action_just_pressed("left_click") && can_shoot:
		# Instanciar proyectil
		var new_projectile = load("res://entities/player/projectile.tscn")
		var projectile_instance = new_projectile.instantiate()
		projectile_instance.spawn_pos = global_position
		projectile_instance.target_pos = get_global_mouse_position()
		call_deferred("add_sibling", projectile_instance)
		
		# Recargar proyectil
		can_shoot = false
		await get_tree().create_timer(0.4).timeout
		can_shoot = true

func handle_animation(input_direction):
	# Power-up actual para hacer las animaciones
	var current_weapon = WEAPON[weapon_index]
	
	# Caminar en diferentes direcciones (debe haber alguna mejor forma de hacer esto)
	if input_direction == Vector2(0,0):
		current_anim_state = "idle"
	elif input_direction[0] == 0:
		if input_direction[1] > 0: current_anim_state = "walk_down"
		elif input_direction[1] < 0: current_anim_state = "walk_up"
	elif input_direction[0] != 0:
		current_anim_state = "walk_side"
		if input_direction[0] < 0: animated_sprite_2d.scale.x = -1
		else: animated_sprite_2d.scale.x = 1
	
	animated_sprite_2d.play(current_weapon + "_" + current_anim_state)

#func handle_animation(input_direction):
#	# Caminar en diferentes direcciones (debe haber alguna mejor forma de hacer esto)
#	if input_direction == Vector2(0,0):
#		animated_sprite_2d.play("idle")
#	elif input_direction[0] == 0:
#		if input_direction[1] > 0: animated_sprite_2d.play("walk_down")
#		elif input_direction[1] < 0: animated_sprite_2d.play("walk_up")
#	elif input_direction[0] != 0:
#		animated_sprite_2d.play("walk_side")
#		if input_direction[0] < 0: animated_sprite_2d.scale.x = -1
#		else: animated_sprite_2d.scale.x = 1
		
######################################################################### SEÑALES ##############################################################
func _on_hitbox_area_entered(area):
	if area is PowerUp:
		if area.type == "machinegun":
			weapon_index = 1
		area.queue_free()
