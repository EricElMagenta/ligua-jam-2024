extends Node2D

@onready var enemy_scene = preload("res://entities/enemies/enemy-1.tscn")
@onready var car_scene = preload("res://entities/hazards/car.tscn")

@onready var collision_polygon_2d = $StaticBody2D/CollisionPolygon2D
@onready var polygon_2d = $StaticBody2D/CollisionPolygon2D/Polygon2D
@onready var timer = $Timer
@onready var level_time_label = $UI/Timer/TimePanel/CenterContainer/LevelTimeLabel
@onready var level_timer = $UI/Timer/TimePanel/CenterContainer/LevelTimer
@onready var score_label = $UI/Score/ScorePanel/CenterContainer/ScoreLabel
@onready var ammo_label = $UI/Ammo/Ammopanel/AmmoLabel
@onready var player = $Player

@onready var car_timer = $CarTimer

var lower_spawn_rate_flag = true
var spawn_modifier = 1.0
var level_time = 0.0
var score = 0
var traffic_time


func _ready():
	polygon_2d.polygons = collision_polygon_2d.polygon
	level_timer.start()
	Events.enemy_defeated.connect(add_score)

func _physics_process(delta):
	level_time_label.text = "%02d:%02d" % countdown()
	score_label.text = "$" + str(score)
	level_time = Time.get_ticks_msec()
	update_ammo()
	
	traffic_time = countdown()[1]
	if traffic_time%20==0 && level_time/1000 > 3: 
		traffic_chaos()
	
	#traffic_chaos()
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
	
func _on_car_timer_timeout():
	var new_car = car_scene.instantiate()
	new_car.position=Vector2(472, randi_range(50, 200))
	call_deferred("add_child", new_car) 

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
	
func traffic_chaos():
	car_timer.start()
	await get_tree().create_timer(5).timeout
	car_timer.stop()
