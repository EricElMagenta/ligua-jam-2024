extends Node2D

@onready var enemy_scene = preload("res://entities/enemies/enemy-1.tscn")

@onready var collision_polygon_2d = $StaticBody2D/CollisionPolygon2D
@onready var polygon_2d = $StaticBody2D/CollisionPolygon2D/Polygon2D
@onready var timer = $Timer
@onready var level_time_label = $UI/Timer/TimePanel/CenterContainer/LevelTimeLabel
@onready var level_timer = $UI/Timer/TimePanel/CenterContainer/LevelTimer
@onready var score_label = $UI/Score/ScorePanel/CenterContainer/ScoreLabel
@onready var ammo_label = $UI/Ammo/Ammopanel/AmmoLabel
@onready var player = $Player


var lower_spawn_rate_flag = true
var spawn_modifier = 1.0
var level_time = 0.0
var score = 0

func _ready():
	polygon_2d.polygons = collision_polygon_2d.polygon
	level_timer.start()
	Events.enemy_defeated.connect(add_score)

func _physics_process(delta):
	level_time_label.text = "%02d:%02d" % countdown()
	score_label.text = "$" + str(score)
	level_time = Time.get_ticks_msec()
	update_ammo()
	#if level_time % 100 == 0: 
	#	if timer.wait_time > 0.1 : timer.wait_time -= 0.1
	#	else: timer.wait_time = 0.1
	lower_spawn_rate()

func countdown():
	var time_left = level_timer.time_left
	var minutes = floor(time_left / 60)
	var seconds =  int(time_left) % 60
	return [minutes, seconds]

func _on_timer_timeout():
	var spawn_h_range = [-20, 472]
	var spawn_h = spawn_h_range[randi() % spawn_h_range.size()]
	var enemy = enemy_scene.instantiate()
	enemy.position = Vector2(spawn_h, randi_range(16, 240))
	call_deferred("add_child", enemy)
	
func lower_spawn_rate():

	if int(level_time)/1000 % 10 == 0 && lower_spawn_rate_flag:
		lower_spawn_rate_flag = false
		await get_tree().create_timer(1).timeout
		lower_spawn_rate_flag = true
		if timer.wait_time <= 0.1: 
			return
		timer.wait_time -= 0.1

func update_ammo():
	ammo_label.text = str(player.update_ammo())

func add_score():
	score += 1000
