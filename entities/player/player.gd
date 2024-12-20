extends CharacterBody2D
class_name Player

const HEALTH_MAX = 100
const SPEED = 100.0
const WEAPON = ["default", "machinegun", "blowgun"]

var can_shoot = true # COOLDOWN
var damage_blink = false # INVENCIBILIDAD DESPUÉS DE RECIBIR DAÑO
var weapon_index = 0
var current_anim_state = "idle"
var has_weapon = [1, 0, 0]
var defeated : bool

# MUNICIONES
var machinegun_ammo = 0
var blowgun_ammo = 0
var ammo = 0

# PUNTAJE
var score = 0

# AUDIO
@onready var sfx_damage = $SFX/SFXDamage
@onready var sfx_power_up = $SFX/SFXPowerUp
@onready var sfx_swapping = $SFX/SFXSwapping

@onready var health = $"../UI/Healthbar/Health"
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var projectile = load("res://entities/player/projectile.tscn")
@onready var collision_shape_2d = $CollisionShape2D
@onready var camera_2d = $Camera2D

func _ready():
	health.value = HEALTH_MAX
	collision_shape_2d.disabled = false
	defeated = false
	process_mode = 0

func _physics_process(delta):
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	handle_movement(input_direction)
	handle_animation(input_direction)
	if weapon_index == 0: shooting_default()
	elif weapon_index == 1: shooting_machinegun()
	elif weapon_index == 2: shooting_blowgun()
	swap_weapon()
	move_and_slide()
	if health.value < 1:
		defeated = true
		collision_shape_2d.disabled = true
		player_defeated()
		#get_tree().reload_current_scene()

######################################################################### FUNCIONES AUXILIARES ############################################
func handle_movement(input_direction):
	if !is_on_wall() || !is_on_ceiling() : velocity = input_direction * SPEED

func on_take_damage():
	sfx_damage.play()
	# Inmunidad post-daño
	if health.value > 8: damage_blink = true
	if damage_blink:
		for i in 4: # Parpadear después de que te peguen
			self.modulate.a = 0
			await get_tree().create_timer(0.2).timeout
			self.modulate.a = 1
			await get_tree().create_timer(0.2).timeout
	damage_blink = false

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
	
func shooting_default():
	if Input.is_action_pressed("left_click") && can_shoot:
		# Instanciar proyectil
		var new_projectile = load("res://entities/player/projectile.tscn")
		var projectile_instance = new_projectile.instantiate()
		projectile_instance.spawn_pos = global_position
		projectile_instance.target_pos = get_global_mouse_position()
		projectile_instance.weapon_index = weapon_index
		call_deferred("add_sibling", projectile_instance)
		
		# Recargar proyectil
		can_shoot = false
		await get_tree().create_timer(0.4).timeout
		can_shoot = true
		
func shooting_machinegun():
	if Input.is_action_pressed("left_click") && can_shoot:
		machinegun_ammo -= 1
		# Instanciar el proyectil
		var new_projectile = load("res://entities/player/projectile.tscn")
		var projectile_instance = new_projectile.instantiate()
		projectile_instance.spawn_pos = global_position
		projectile_instance.target_pos = get_global_mouse_position()
		projectile_instance.weapon_index = weapon_index
		call_deferred("add_sibling", projectile_instance)
		
		can_shoot = false
		await get_tree().create_timer(0.05).timeout
		can_shoot = true
		
	if machinegun_ammo <= 0: 
		has_weapon[1] = 0
		weapon_index = 0

func shooting_blowgun():
	if Input.is_action_pressed("left_click") && can_shoot:
		blowgun_ammo -= 1
		# Instanciar el proyectil
		var new_projectile = load("res://entities/player/projectile.tscn")
		var projectile_instance = new_projectile.instantiate()
		projectile_instance.spawn_pos = global_position
		projectile_instance.target_pos = get_global_mouse_position()
		projectile_instance.weapon_index = weapon_index
		call_deferred("add_sibling", projectile_instance)
		
		can_shoot = false
		await get_tree().create_timer(0.20).timeout
		can_shoot = true
		
	if blowgun_ammo <= 0: 
		has_weapon[2] = 0
		weapon_index = 0
	

func update_ammo():
	if weapon_index == 0: return '-'
	elif weapon_index == 1: return machinegun_ammo
	elif weapon_index == 2: return blowgun_ammo
	
func swap_weapon():
	if Input.is_action_just_pressed("swap_weapon_right"):
		var swap_direction = "right"
		var next_weapon = next_weapon_available(swap_direction)
		weapon_index = next_weapon
		
		#var next_weapon = next_weapon_available(swap_direction)
		#if next_weapon_available(swap_direction):
			#weapon_index = next_weapon_available(swap_direction)
		#if !next_weapon_available(weapon_index): return
		#if weapon_index == len(has_weapon)-1: weapon_index = 0
		#else: weapon_index += 1
		
	if Input.is_action_just_pressed("swap_weapon_left"):
		var swap_direction = "left"
		var next_weapon = next_weapon_available(swap_direction)
		weapon_index = next_weapon
		
func next_weapon_available(swap_direction):
	if swap_direction == "right":
		for i in range(weapon_index+1, len(has_weapon), 1):
			if has_weapon[i] == 1:
				sfx_swapping.play()
				return i
		return 0
	
	if swap_direction == "left":
		if weapon_index == 0:
			for i in range(len(has_weapon)-1, 0, -1):
				if has_weapon[i] == 1:
					sfx_swapping.play()
					return i
		else: 
			for i in range(weapon_index-1, 0, -1):
				if has_weapon[i] == 1:
					sfx_swapping.play()
					return i
		return 0
	
func player_defeated():
	rotation += 1
	position += Vector2(-5, -5)

######################################################################### SEÑALES ##############################################################
func _on_hitbox_area_entered(area):
	if area is PowerUp:
		sfx_power_up.play()
		if area.type == "machinegun":
			machinegun_ammo += 20
			has_weapon[1] = 1
			
		elif area.type == "blowgun":
			blowgun_ammo += 30
			has_weapon[2] = 1
		area.queue_free()
