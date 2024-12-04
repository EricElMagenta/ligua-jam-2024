extends Node2D

@onready var collision_polygon_2d = $StaticBody2D/CollisionPolygon2D
@onready var polygon_2d = $StaticBody2D/CollisionPolygon2D/Polygon2D
@onready var enemy_scene = preload("res://entities/enemies/enemy-1.tscn")
@onready var timer = $Timer

var damage = 8

func _ready():
	polygon_2d.polygons = collision_polygon_2d.polygon

func _on_timer_timeout():
	var spawn_h_range = [-20, 472]
	var spawn_h = spawn_h_range[randi() % spawn_h_range.size()]
	var enemy = enemy_scene.instantiate()
	enemy.position = Vector2(spawn_h, randi_range(16, 240))
	call_deferred("add_child", enemy)
